extends CharacterBody2D

@onready var slime = $AnimatedSprite2D

const SPEED = 120
const direction = 1 # Moving right
var isFriendly = true

func setisFriendly(status: bool) -> void:
	isFriendly = status 

func _physics_process(delta: float) -> void:
	if isFriendly and position.x >= 975:
		slime.play("attack")
		velocity.x = 0
	else:
		slime.play("walk")
		velocity.x = direction * SPEED		
	move_and_slide()
