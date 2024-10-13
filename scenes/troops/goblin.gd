extends "./base_troop.gd"

func _ready() -> void:
	MOVE_SPEED = 100
	ATTACK_RANGE = 30
	ATTACK_DMG = 3
	ATTACK_SPD = 0.5
	MAX_HP = 65
	GOLD_DROP = Constants.GOBLIN_PRICE / 3
	SPAWN_WAIT = 0.8
	SPEED_SCALE = 2.0
	super()
