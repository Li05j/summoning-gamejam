extends CharacterBody2D

@onready var goblin = $AnimatedSprite2D

const MOVE_SPEED = 180 # Default speed
const ATTACK_RANGE = 5 # Default DUMMY attack range
const ATTACK_DMG = 5 # Default atk
const ATTACK_SPD = 0.4 # Default interval between atks in seconds
const MAX_HP = 50 # Default hp
const GOLD_DROP = 15 # Default gold drop upon defeat

const friendly_turrent_x = 130 # Default friendly tower x-coord
const enemy_turrent_x = 975 # Default enemy tower x-coord

var current_hp = MAX_HP
var current_target = null  # Holds the target enemy

# Stuff that will change if enemy
var is_friendly = true # Default friendly
var direction = 1 # Default moving right

func _ready() -> void:
	if not is_friendly:
		goblin.flip_h = true

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
		goblin.play("attack")
		velocity.x = 0
	elif !is_friendly and position.x <= friendly_turrent_x:
		goblin.play("attack")
		velocity.x = 0
	else:
		velocity.x = direction * MOVE_SPEED
		goblin.play("walk")
	move_and_slide()
