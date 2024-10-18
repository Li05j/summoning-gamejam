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

var is_dead = false
var is_cc = false
var is_invincible = true
var current_hp: float
#var current_target = null  		# Holds the current target enemy
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
	
	deathSound.bus = "SFX"
	deathSound.max_polyphony = 5
	
	if !is_friendly:
		sprite.flip_h = true # flip sprite to face left
		target_troop_container = game_menu.get_node("NonUI/Friend_Troop_Container")
	else:
		target_troop_container = game_menu.get_node("NonUI/Enemy_Troop_Container")

	sprite.play("spawn")
	
func _physics_process(delta: float) -> void:
	if !is_dead:
		attack_if_any_target_in_range()
		move_and_slide()

func add_attack_timer() -> void:
	attack_timer = Timer.new()
	attack_timer.wait_time = TROOP_OBJ.get("ATTACK_SPD", -1)
	attack_timer.one_shot = true
	attack_timer.timeout.connect(_on_attack_timer_timeout)
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
	invincible_timer.wait_time = 0.5 # extra 0.5 sec invincible time
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
	if is_dead or is_cc or !spawn_timer.is_stopped() or sprite.animation == "attack":
		return
		
	if is_hitting_base:
		attack()
		return
	# If base is in range, then attack	
	elif (is_friendly and position.x >= attack_enemy_base_x) or (!is_friendly and position.x <= attack_friend_base_x):
		is_hitting_base = true
		attack()
		return
			
	for unit in target_troop_container.get_children():
		if abs(unit.position.x - position.x) <= TROOP_OBJ.get("ATTACK_RANGE", -1) and is_instance_valid(unit) and !unit.is_dead:
			attack()
			return # There exist a target in range, start attack animation
			
	# If nothing is found
	if spawn_timer.is_stopped():
		velocity.x = direction * TROOP_OBJ.get("MOVE_SPEED", -1)
		attack_timer.stop()
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
	
# This is meant to be a virtual function - override if troop has special effects
func attack_special_effects(troop) -> void:
	pass

#func find_target() -> void:
	#if !spawn_timer.is_stopped() or is_dead:
		#return # don't do anything while spawning or dead
	#
	## Check if target is still valid (not dead yet)
	#if current_target and is_instance_valid(current_target):
		#if current_target.is_dead:
			#current_target = null # target is playing its death sound
		#return
	#else:
		#current_target = null
		#
	#var container_name;
	#var container_node;
	#if is_friendly:
		#container_name = "Enemy_Troop_Container"
	#else:
		#container_name = "Friend_Troop_Container"
	#container_node = game_menu.get_node("NonUI/" + container_name)
#
	#for unit in container_node.get_children():
		#if abs(unit.position.x - position.x) <= TROOP_OBJ.get("ATTACK_RANGE", -1) and !unit.is_invincible and !unit.is_dead:
			#current_target = unit
			#is_hitting_base = false # Stop hitting base - prio hitting units
			#attack()
			#return # Found target, no need to continue searching
			#
	## If no units are in sight but the tower is
	#if is_hitting_base:
		#return
#
	## If didn't find target at all
	#if is_friendly and position.x >= attack_enemy_base_x:
		#is_hitting_base = true
		#attack()
	#elif !is_friendly and position.x <= attack_friend_base_x:
		#is_hitting_base = true
		#attack()
	#else:
		#if spawn_timer.is_stopped():
			#velocity.x = direction * TROOP_OBJ.get("MOVE_SPEED", -1)
			#attack_timer.stop()
			#sprite.play("walk")

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
	
# When unit is cc'd
func set_is_controlled() -> void:
	is_cc = true
	attack_timer.stop()
	sprite.play("idle")
	
# Transition from spawn to walk after spawning
func _on_spawn_animation_done() -> void:
	sprite.play("walk")
	sprite.speed_scale = TROOP_OBJ.get("SPEED_SCALE", -1)
	invincible_timer.start()
	
func _on_invincible_timeout() -> void:
	is_invincible = false

func _on_attack_timer_timeout() -> void:
	attack()
	
func _on_dead_sfx_timer_timeout() -> void:
	queue_free()

func _on_animated_sprite_2d_animation_looped() -> void:
	if !is_dead and sprite.animation == "attack":
		resolve_attack()
		sprite.play("idle")  # Idle while waiting for next attack
		attack_timer.start()
