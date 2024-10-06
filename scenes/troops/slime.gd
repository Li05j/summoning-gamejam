extends CharacterBody2D


@onready var slime = $AnimatedSprite2D

const MOVE_SPEED = 110 # Default speed
const ATTACK_RANGE = 50 # Default DUMMY attack range
const ATTACK_DMG = 15 # Default atk
const ATTACK_SPD = 1 # Default rate of atk
const MAX_HP = 35 # Default hp
const GOLD_DROP = 25 # Default gold drop upon defeat

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
		slime.play("attack")
		velocity.x = 0
	elif !is_friendly and position.x <= friendly_turrent_x:
		slime.play("attack")
		velocity.x = 0
	else:
		velocity.x = direction * MOVE_SPEED
		slime.play("walk")
	move_and_slide()
