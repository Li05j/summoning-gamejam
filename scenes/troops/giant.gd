extends CharacterBody2D

const MOVE_SPEED = 75 # Default speed
const ATTACK_RANGE = 10 # Default DUMMY attack range
const ATTACK_DMG = 35 # Default atk
const ATTACK_SPD = 2 # Default rate of atk
const MAX_HP = 200 # Default hp
const GOLD_DROP = 100 # Default gold drop upon defeat

var friendly_turrent_x = 130 # Default friendly tower x-coord
var enemy_turrent_x = 975 # Default enemy tower x-coord

var current_hp = MAX_HP

# Stuff that will change if enemy
var is_friendly = true # Default friendly
var direction = 1 # Default moving right

func set_enemy(spawn_pos: Vector2) -> void:
	is_friendly = false
	position = spawn_pos
	direction = -direction
	
func take_dmg(damage: int) -> void:
	current_hp -= damage
	if current_hp <= 0:
		queue_free() # gracefully deletes this instance, i.e. self destruct

func _physics_process(delta: float) -> void:
	if is_friendly and position.x >= enemy_turrent_x:
		velocity.x = 0
	elif !is_friendly and position.x <= friendly_turrent_x:
		velocity.x = 0
	else:
		velocity.x = direction * MOVE_SPEED
	move_and_slide()
