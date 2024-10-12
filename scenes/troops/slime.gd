extends "./base_troop.gd"

func _ready() -> void:
	MOVE_SPEED = 80
	ATTACK_RANGE = 160
	ATTACK_DMG = 30
	ATTACK_SPD = 2.5
	MAX_HP = 35
	GOLD_DROP = Constants.SLIME_PRICE / 2
	SPAWN_WAIT = 0.8
	SPEED_SCALE = 1.0
	super()
