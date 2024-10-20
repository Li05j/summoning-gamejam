extends "./base_troop.gd"

func _ready() -> void:
	TROOP_OBJ = T.MONSTER_T["GIANT"].duplicate()
	super()

func attack_special_effects(troop) -> void:
	var knockback_duration = 1.0 # seconds
	troop.knockback(knockback_duration)
