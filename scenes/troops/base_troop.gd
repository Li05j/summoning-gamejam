extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D
@onready var deathSound = $AudioStreamPlayer

var game_menu;

var action_timer: Timer
var spawn_timer: Timer

@export var MOVE_SPEED: int 	# Movement speed
@export var ATTACK_RANGE: int 	# Attack range
@export var ATTACK_DMG: int 	# Atk damage
@export var ATTACK_SPD: float 	# Attack every ATTACK_SPD seconds, i.e. rate
@export var MAX_HP: float 		# Max hp
@export var GOLD_DROP: int 		# Gold drop on death

@export var SPAWN_WAIT: float	# Spawn animation time in seconds
# Animation rate - low rate means animation loop takes longer, i.e. also affects attack prep time
@export var SPEED_SCALE: float

# Range where tropp will start attacking the base
var attack_friend_base_x: int
var attack_enemy_base_x: int

var current_hp: int
var current_target = null  		# Holds the current target enemy
var is_hitting_tower = false 	# If it reached the end (i.e. enemy tower)

# Stuff that will change if enemy, use set_as_enemy()
var is_friendly = true 			# Default friendly troop
var direction = 1 				# Default moving right, -1 is moving left

func _ready() -> void:
	add_timer()
	add_spawn_timer()  # Add the spawn timer
	current_hp = MAX_HP
	attack_friend_base_x = Constants.FRIENDLY_BASE_X + ATTACK_RANGE
	attack_enemy_base_x = Constants.ENEMY_BASE_X - ATTACK_RANGE
	
	game_menu = get_tree().root.get_node("GameMenu")
	
	if not is_friendly:
		sprite.flip_h = true # flip sprite to face left
	sprite.play("spawn")
	
func _physics_process(delta: float) -> void:
	change_opacity()
	find_target()
	if is_friendly and position.x >= attack_enemy_base_x:
		is_hitting_tower = true
		velocity.x = 0
	elif !is_friendly and position.x <= attack_friend_base_x:
		is_hitting_tower = true
		velocity.x = 0
	elif current_target:
		velocity.x = 0
	else:
		if spawn_timer.is_stopped():
			velocity.x = direction * MOVE_SPEED
			sprite.play("walk")
	move_and_slide()

func add_timer() -> void:
	action_timer = Timer.new()
	action_timer.wait_time = ATTACK_SPD
	action_timer.autostart = true
	add_child(action_timer)
	action_timer.timeout.connect(_on_action_timeout)
	
func add_spawn_timer() -> void:
	spawn_timer = Timer.new()
	spawn_timer.wait_time = SPAWN_WAIT
	spawn_timer.one_shot = true
	add_child(spawn_timer)
	spawn_timer.start()
	spawn_timer.timeout.connect(_on_spawn_animation_done)

func set_as_enemy(spawn_pos: Vector2) -> void:
	is_friendly = false
	position = spawn_pos
	direction = -direction
	
func take_dmg(damage: int) -> bool:
	current_hp -= damage
	if current_hp <= 0:
		deathSound.play()
		if !is_friendly:
			game_menu.player_current_gold += GOLD_DROP
		else:
			game_menu.get_node("NonUI/EnemyAI/").enemy_current_gold += GOLD_DROP
		queue_free() # Gracefully deletes this instance, i.e. self destruct
		return true # Unit died from the attack
	return false

func find_target() -> void:
	if is_instance_valid(current_target):
		return
	else:
		current_target = null
		
	var container_name;
	var container_node;
	if is_friendly:
		container_name = "Enemy_Troop_Container"
	else:
		container_name = "Friend_Troop_Container"
	container_node = game_menu.get_node("NonUI/" + container_name)

	for unit in container_node.get_children():
		if abs(unit.position.x - position.x) <= ATTACK_RANGE:
			current_target = unit
			velocity.x = 0 # Stop moving when target is not NULL
			
func change_opacity() -> void:
	var hp_percentage: float = current_hp / MAX_HP
	sprite.modulate.a = lerp(0.25, 1.0, hp_percentage)
	
# Transition from spawn to walk after spawning
func _on_spawn_animation_done() -> void:
	sprite.play("walk")
	sprite.speed_scale = SPEED_SCALE
		
func _on_action_timeout() -> void:
	if velocity.x > 0:
		sprite.play("walk")
	else:
		sprite.play("attack")

func _on_animated_sprite_2d_animation_looped() -> void:
	if sprite.animation == "attack":
		if current_target != null and current_target.take_dmg(ATTACK_DMG):
			current_target = null
		elif is_hitting_tower:
			game_menu.damage_base(ATTACK_DMG, is_friendly)
		sprite.play("walk")  # Go back to walk after attack finishes

# ONLY START action timer when attacking - the attack and attack speed thing needs to be overhauled
# target selection could be better, need more thought on these
