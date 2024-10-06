extends Control
var slime_scene = preload("res://scenes/troops/slime.tscn") # Preload slime scene



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Process is running.")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"): # Z key is default mapped to ui_accept
		summon_slime()
	if Input.is_action_just_pressed("Summon_1"):
		_on_q_pressed() 
	if Input.is_action_just_pressed("Summon_2"): 
		_on_w_pressed()
	if Input.is_action_just_pressed("Summon_3"): 
		_on_e_pressed()

			
func summon_slime():
	print("Trying to summon slime.")
	var slime_instance = slime_scene.instantiate()
	slime_instance.position = Vector2(400, 300) # Dummy position
	add_child(slime_instance)


func _on_q_pressed() -> void:
	summon_slime()
	print("Summoned Slime with Q")

func _on_w_pressed() -> void:
	summon_slime()
	print("Summoned Slime with Q")

func _on_e_pressed() -> void:
	summon_slime()
	print("Summoned Slime with Q")
