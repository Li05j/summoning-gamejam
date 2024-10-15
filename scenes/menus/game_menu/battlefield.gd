extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Friend_Base/base_sprite.play("friend_base")
	$Enemy_Base/base_sprite.play("enemy_base")
	$Enemy_Base/base_hp_bar.position.x = GLOBAL_C.ENEMY_BASE_HP_BAR_X_OFFSET
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
