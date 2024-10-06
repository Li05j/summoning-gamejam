extends CharacterBody2D

const SPEED = 200
const direction = 1 # Moving right
var isFriendly = true

func setisFriendly(status: bool) -> void:
	isFriendly = status 

func _physics_process(delta: float) -> void:
	if isFriendly and position.x >= 975:
		velocity.x = 0
	else:
		velocity.x = direction * SPEED		
	move_and_slide()
