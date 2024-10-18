extends "./base_troop.gd"

func _ready() -> void:
	TROOP_OBJ = T.MONSTER_T["GIANT"].duplicate()
	super()

func attack_special_effects(troop) -> void:
	#troop.set_is_controlled()
	#troop.velocity.x = -direction * GLOBAL_C.KNOCK_BACK_SPEED
	pass
