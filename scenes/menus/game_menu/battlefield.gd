extends Node2D
# DOES NOTHING RIGHT NOW

#var base_scene = preload("res://scenes/buildings/base.tscn")\
@onready var good_tower = $Good_Tower
@onready var bad_tower = $Bad_Tower


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	init_base()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	good_tower.play("vibe")
	bad_tower.play("vibe")	

func init_base() -> void:
	#var base_instance = base_scene.instantiate()
	#base_instance.position = Vector2(50, 50)
	#add_child(base_instance)
	pass
