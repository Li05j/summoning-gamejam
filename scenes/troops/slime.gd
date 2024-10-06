extends CharacterBody2D

const SPEED = 100
const direction = 1 # Moving right

func _physics_process(delta: float) -> void:
	velocity.x = direction * SPEED
	move_and_slide()
