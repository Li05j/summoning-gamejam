extends CharacterBody2D

@onready var giant = $AnimatedSprite2D

const SPEED = 90
const direction = 1 # Moving right
var isFriendly = true

func setisFriendly(status: bool) -> void:
	isFriendly = status 

func _physics_process(delta: float) -> void:
	if isFriendly and position.x >= 950:
		giant.play("attack")
		velocity.x = 0
	else:
		velocity.x = direction * SPEED		
		giant.play("walk")
	move_and_slide()
