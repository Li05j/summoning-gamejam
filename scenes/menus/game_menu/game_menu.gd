extends Control
var slime_scene = preload("res://scenes/troops/slime.tscn") # Preload slime scene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Process is running.")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"): # Z key is default mapped to ui_accept
		summon_slime()

func summon_slime():
	print("Trying to summon slime.")
	var slime_instance = slime_scene.instantiate()
	slime_instance.position = Vector2(400, 300) # Dummy position
	add_child(slime_instance)
