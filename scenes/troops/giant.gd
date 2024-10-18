extends "./base_troop.gd"

func _ready() -> void:
	TROOP_OBJ = T.MONSTER_T["GIANT"].duplicate()
	super()
