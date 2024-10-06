extends CharacterBody2D

@onready var giant = $AnimatedSprite2D

var action_timer: Timer
var spawn_timer: Timer

const MOVE_SPEED = 75 # Default speed
const ATTACK_RANGE = 75 # Default DUMMY attack range
const ATTACK_DMG = 35 # Default atk
const ATTACK_SPD = 2 # Default rate of atk
const MAX_HP = 500 # Default hp
const GOLD_DROP = 100 # Default gold drop upon defeat

const SPAWN_WAIT = 1

const friendly_turrent_x = 130 + ATTACK_RANGE # Default friendly tower x-coord
const enemy_turrent_x = 975 - ATTACK_RANGE # Default enemy tower x-coord

var current_hp = MAX_HP
var current_target = null  # Holds the target enemy
var is_hitting_tower = false # If it reached the end (i.e. enemy tower)

# Stuff that will change if enemy
var is_friendly = true # Default friendly
var direction = 1 # Default moving right


# Add this function

# Add this function to transition from spawn to walk
func _on_spawn_animation_done() -> void:
	giant.play("walk")

func _ready() -> void:
	add_timer()
	giant.play("spawn")
	add_spawn_timer()  # Add the spawn timer
	if not is_friendly:
		giant.flip_h = true

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
	container_node = get_parent().get_parent().get_node(container_name)

	for unit in container_node.get_children():
		if abs(unit.position.x - position.x) <= ATTACK_RANGE:
			current_target = unit
			velocity.x = 0 # Stop moving when target is not NULL

func _physics_process(delta: float) -> void:
	find_target()
	if is_friendly and position.x >= enemy_turrent_x:
		is_hitting_tower = true
		velocity.x = 0
	elif !is_friendly and position.x <= friendly_turrent_x:
		is_hitting_tower = true
		velocity.x = 0
	elif current_target:
		velocity.x = 0
	else:
		if spawn_timer.is_stopped():
			velocity.x = direction * MOVE_SPEED
			giant.play("walk")
	move_and_slide()
		
func _on_action_timeout() -> void:
	if velocity.x > 0:
		giant.play("walk")
	else:
		giant.play("attack")
		if is_hitting_tower:
			if is_friendly:
				get_parent().get_parent().damageBadTower(ATTACK_DMG)
			else:
				get_parent().get_parent().damageGoodTower(ATTACK_DMG)
		if current_target != null and current_target.take_dmg(ATTACK_DMG):
			current_target = null

func _on_animated_sprite_2d_animation_looped() -> void:
	if giant.animation == "attack":
		giant.play("walk")  # Go back to walk after attack finishes
