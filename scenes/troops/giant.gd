extends "./base_troop.gd"

func _ready() -> void:
	TROOP_OBJ = T.MONSTER_T["GIANT"].duplicate()
	super()

func attack_special_effects(troop) -> void:
	# knockback duration is 1.25 - 1.75 seconds, a bit of rng
	var knockback_duration = 1.5 # seconds
	var fluc_bound = 0.25 # seconds
	troop.knockback(knockback_duration, fluc_bound)
