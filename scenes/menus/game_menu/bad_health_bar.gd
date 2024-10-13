extends TextureProgressBar

@export var gameState: Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gameState.badTowerHealthChange.connect(update)
	update()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func update() -> void:
	value = gameState.bad_tower_health * 100 / Constants.BASE_MAX_HP
