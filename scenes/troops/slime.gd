extends CharacterBody2D

const MOVE_SPEED = 110 # Default speed
const ATTACK_RANGE = 50 # Default DUMMY attack range
const ATTACK_DMG = 15 # Default atk
const ATTACK_SPD = 1 # Default rate of atk
const MAX_HP = 35 # Default hp
const GOLD_DROP = 25 # Default gold drop upon defeat

var current_hp = MAX_HP

# Stuff that will change if enemy
var direction = 1 # Default moving right
var is_friendly = true # Default friendly
var end_pos = 975 # Default enemy tower x-coord
	
# This is basically a constructor.
# For an enemy, move_direction should be -1 and friendly_status is false.
func initialize(
	start_position: Vector2, 
	move_direction: int, 
	friendly_status: bool, 
	end_position: int,
) -> void:
	position = start_position
	direction = move_direction
	is_friendly = friendly_status
	
func take_dmg(damage: int) -> void:
	current_hp -= damage
	if current_hp <= 0:
		queue_free() # gracefully deletes this instance, i.e. self destruct

func _physics_process(delta: float) -> void:
	if is_friendly and position.x >= end_pos:
		velocity.x = 0
	else:
		velocity.x = direction * MOVE_SPEED
	move_and_slide()
