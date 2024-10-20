extends "./base_troop.gd"

var projectile_scene = preload("res://scenes/troops/projectile/slime_projectile.tscn")

func _ready() -> void:
	TROOP_OBJ = T.MONSTER_T["SLIME"].duplicate()
	super()

func shoot_projectile():
	var projectile_instance: PROJECTILE = projectile_scene.instantiate()
	add_child(projectile_instance)
	var projectile_obj = TROOP_OBJ.get("PROJECTILE", null)
	if projectile_obj:
		projectile_instance.init(
			projectile_obj.get("Y_OFFSET"),
			projectile_obj.get("RANGE_MOD"),
			projectile_obj.get("PARABOLA"),
			projectile_obj.get("RATE"),
			is_friendly
		)
