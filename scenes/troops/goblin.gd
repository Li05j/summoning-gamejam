extends CharacterBody2D

@onready var goblin = $AnimatedSprite2D

const SPEED = 200
const direction = 1 # Moving right
var isFriendly = true

func setisFriendly(status: bool) -> void:
	isFriendly = status 

func _physics_process(delta: float) -> void:
	if isFriendly and position.x >= 975:
		goblin.play("attack")
		velocity.x = 0
	else:
		velocity.x = direction * SPEED		
		goblin.play("walk")
	move_and_slide()
