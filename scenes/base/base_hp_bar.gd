extends TextureProgressBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	min_value = 0
	max_value = GLOBAL_C.BASE_MAX_HP
	value = max_value

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func take_dmg(dmg: int) -> bool:
	value -= dmg
	if value <= min_value:
		get_parent().get_node("base_sprite/").play("destroyed")
		return true
	return false

func _on_auto_regen_timer_timeout() -> void:
	if GAME_STATE.win == null:
		value += 2
		if value > max_value:
			value = max_value
