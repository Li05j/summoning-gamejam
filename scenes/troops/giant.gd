extends "./base_troop.gd"

func _ready() -> void:
	MOVE_SPEED = 25
	ATTACK_RANGE = 75
	ATTACK_DMG = 60
	ATTACK_SPD = 3
	MAX_HP = 500
	GOLD_DROP = Constants.GOBLIN_PRICE / 2
	SPAWN_WAIT = 2.0
	SPEED_SCALE = 0.5
	super()
