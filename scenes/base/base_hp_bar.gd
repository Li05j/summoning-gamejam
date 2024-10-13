extends TextureProgressBar


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	min_value = 0
	max_value = Constants.BASE_MAX_HP
	value = max_value

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func take_dmg(dmg: int) -> bool:
	value -= dmg
	if value <= min_value:
		return true
	return false
