extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D
@onready var deathSound = $death

var game_menu
var target_troop_container

var attack_timer: Timer
var spawn_timer: Timer
var invincible_timer: Timer
var dead_sfx_timer: Timer

@export var TROOP_OBJ: Dictionary	# All the stat info about the troop

# Range where tropp will start attacking the base
var attack_friend_base_x: int
var attack_enemy_base_x: int

# The ground
var ground_y: int

var just_summoned = true # invincible and cc immune
var is_spawning = true
var is_dead = false
var is_cc = false
var is_invincible = true

var current_hp: float

var is_hitting_base = false 	# If it reached the end (i.e. enemy tower)

# Stuff that will change if enemy, use set_as_enemy()
var is_friendly = true 			# Default friendly troop
var direction = 1 				# Default moving right, -1 is moving left

func _ready() -> void:
	add_attack_timer()
	add_invincible_timer()
	add_spawn_timer()
	add_dead_sfx_timer()
	
	current_hp = TROOP_OBJ.get("MAX_HP", -1)
	attack_friend_base_x = GLOBAL_C.FRIENDLY_BASE_X + TROOP_OBJ.get("ATTACK_RANGE", -1)
	attack_enemy_base_x = GLOBAL_C.ENEMY_BASE_X - TROOP_OBJ.get("ATTACK_RANGE", -1)
	
	game_menu = get_tree().root.get_node("GameMenu")
	
	ground_y = position.y
	
	deathSound.bus = "SFX"
	deathSound.max_polyphony = 5
	
	sprite.animation_looped.connect(_on_animated_sprite_2d_animation_looped)
	sprite.frame_changed.connect(_on_sprite_attack_frame_change)
	
	if !is_friendly:
		sprite.flip_h = true # flip sprite to face left
		target_troop_container = game_menu.get_node("NonUI/Friend_Troop_Container")
	else:
		target_troop_container = game_menu.get_node("NonUI/Enemy_Troop_Container")

	sprite.play("spawn")
	
func _physics_process(delta: float) -> void:
	if !is_dead:
		if position.y < ground_y:
			velocity.y += GLOBAL_C.GRAVITY_Y * delta
		else:
			position.y = ground_y
			
		attack_if_any_target_in_range()
		move_and_slide()

func add_attack_timer() -> void:
	attack_timer = Timer.new()
	attack_timer.wait_time = TROOP_OBJ.get("ATTACK_SPD", -1)
	attack_timer.one_shot = true
	#attack_timer.timeout.connect(_on_attack_timer_timeout)
	add_child(attack_timer)
	
func add_spawn_timer() -> void:
	spawn_timer = Timer.new()
	spawn_timer.wait_time = TROOP_OBJ.get("SPAWN_WAIT", -1)
	spawn_timer.one_shot = true
	spawn_timer.timeout.connect(_on_spawn_animation_done)
	add_child(spawn_timer)
	spawn_timer.start()
	
func add_invincible_timer() -> void:
	invincible_timer = Timer.new()
	invincible_timer.wait_time = 1.0 # extra 1.0 sec invincible time
	invincible_timer.one_shot = true
	invincible_timer.timeout.connect(_on_invincible_timeout)
	add_child(invincible_timer)
	
func add_dead_sfx_timer() -> void:
	dead_sfx_timer = Timer.new()
	dead_sfx_timer.wait_time = deathSound.stream.get_length()
	dead_sfx_timer.one_shot = true
	dead_sfx_timer.timeout.connect(_on_dead_sfx_timer_timeout) # Gracefully deletes this instance after timer, i.e. self destruct
	add_child(dead_sfx_timer)

func set_as_enemy(spawn_pos: Vector2) -> void:
	is_friendly = false
	position = spawn_pos
	direction = -direction
	
func take_dmg(damage: int) -> bool:
	if is_invincible || is_dead:
		return false # unit is still spawning or unit is already dead - they don't take damage
	
	current_hp -= damage
	change_opacity()
	if current_hp <= 0:
		if !is_friendly:
			game_menu.player_current_gold += TROOP_OBJ.get("GOLD_DROP", -1)
		else:
			game_menu.get_node("NonUI/EnemyAI/").enemy_current_gold += TROOP_OBJ.get("GOLD_DROP", -1)
		this_troop_is_dead()
		return true # Unit died from the attack
	return false

func attack_if_any_target_in_range() -> void:
	if is_dead or is_cc or is_spawning or sprite.animation == "attack":
		return
		
	if (is_friendly and position.x >= attack_enemy_base_x) or (!is_friendly and position.x <= attack_friend_base_x):
		is_hitting_base = true
		attack()
		return
	else:
		is_hitting_base = false
			
	for unit in target_troop_container.get_children():
		if abs(unit.position.x - position.x) <= TROOP_OBJ.get("ATTACK_RANGE", -1) and is_instance_valid(unit) and !unit.is_dead:
			attack()
			return # There exist a target in range, start attack animation
			
	# If nothing is found
	velocity.x = direction * TROOP_OBJ.get("MOVE_SPEED", -1)
	#attack_timer.stop()
	sprite.play("walk")
	
func attack() -> void:
	if !is_dead and !is_cc: # only attack when not dead and not cc'd
		velocity.x = 0
		if attack_timer.is_stopped():
			sprite.play("attack")

func resolve_attack() -> void:
	if TROOP_OBJ.get("IS_AOE", false) == true:
		var targets: Array = [];
		for unit in target_troop_container.get_children():
			if abs(unit.position.x - position.x) <= TROOP_OBJ.get("ATTACK_RANGE", -1) and !unit.is_dead:
				targets.append(unit)
		for unit in targets:
			if is_instance_valid(unit):
				unit.take_dmg(TROOP_OBJ.get("ATTACK_DMG", -1))
				attack_special_effects(unit)
	else:
		var is_hitting_unit = false
		for unit in target_troop_container.get_children():
			if abs(unit.position.x - position.x) <= TROOP_OBJ.get("ATTACK_RANGE", -1) and is_instance_valid(unit) and !unit.is_dead:
				is_hitting_unit = true
				unit.take_dmg(TROOP_OBJ.get("ATTACK_DMG", -1))
				break
		if !is_hitting_unit and is_hitting_base:
			game_menu.damage_base(TROOP_OBJ.get("ATTACK_DMG", -1), is_friendly)

func this_troop_is_dead() -> void:
	is_dead = true
	sprite.play("idle")
	sprite.modulate.a = 0
	dead_sfx_timer.start()
	deathSound.play()

# A light visual indicator of unit's HP
func change_opacity() -> void:
	var hp_percentage: float = current_hp / TROOP_OBJ.get("MAX_HP", -1)
	sprite.modulate.a = lerp(0.25, 1.0, hp_percentage)
	
# Transition from spawn to walk after spawning
func _on_spawn_animation_done() -> void:
	sprite.play("walk")
	sprite.speed_scale = TROOP_OBJ.get("SPEED_SCALE", -1)
	velocity.x = direction * TROOP_OBJ.get("MOVE_SPEED", -1)
	is_spawning = false
	invincible_timer.start()
	# TODO: free spawn timer
	
func _on_invincible_timeout() -> void:
	# Currently, invincible is only on spawn, so we can unset both invincible and just_summoned
	# If we can make troops invincible in other ways in the future, this needs to change
	# Also, if this is a 1 time thing, we need to free the timer too
	is_invincible = false
	just_summoned = false

#func _on_attack_timer_timeout() -> void:
	#attack()
	
func _on_dead_sfx_timer_timeout() -> void:
	self.queue_free()

func _on_animated_sprite_2d_animation_looped() -> void:
	if !is_dead and sprite.animation == "attack":
		sprite.play("idle")  	# Idle while waiting for next attack
		attack_timer.start()	# Basic attack cooldown

func _on_sprite_attack_frame_change() -> void:
	# Deal damage on a specific attack animation frame
	if !is_dead and sprite.animation == "attack" and sprite.frame == TROOP_OBJ.get("ATTACK_FRAME", 0):
		resolve_attack()

##########################################################
##### All CC interactions #####
##########################################################

# When unit is cc'd or free of cc
func set_cc(cc: bool) -> void:
	if cc:
		is_cc = true
		attack_timer.stop()
		sprite.play("idle")
	if !cc:
		is_cc = false
		
func knockback(duration: float, fluc_bound: float) -> void:
	if just_summoned: # do not knockback when troop was just summoned
		return
	if TROOP_OBJ.get("CC_IMMUNE", false) == true: # do not knockback if troop is cc immune
		return
	
	set_cc(true)
	
	var fluc = randf_range(-fluc_bound, fluc_bound)
	velocity.x = -direction * TROOP_OBJ.get("MOVE_SPEED", -1)
	velocity.y = -GLOBAL_C.GRAVITY_Y * ((duration + fluc) / 2)
	
	var knockback_timer = Timer.new()
	knockback_timer.name = "knockback_timer"
	knockback_timer.wait_time = duration + fluc
	knockback_timer.one_shot = true
	knockback_timer.timeout.connect(Callable(self, "_on_cc_timeout").bind(knockback_timer.name))
	add_child(knockback_timer)
	knockback_timer.start()

func _on_cc_timeout(timer_name: String) -> void:
	set_cc(false)
	velocity.y = 0
	if get_node(timer_name) and is_instance_valid(get_node(timer_name)):
		get_node(timer_name).queue_free()

##########################################################
##### Virtual Functions #####
##########################################################

func attack_special_effects(troop) -> void:
	pass
