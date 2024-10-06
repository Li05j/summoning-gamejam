extends Control
var slime_scene = preload("res://scenes/troops/slime.tscn") # Preload slime scene
	
var battlefield;
var command_panel;

var summon_location_Vector2: Vector2;

var player_current_gold = 0;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Process is running.")
	battlefield = $VBoxContainer/Battlefield
	command_panel = $VBoxContainer/Command_Panel
	var viewport_y = get_viewport_rect().size.y
	var ground_y = command_panel.get_global_rect().size.y
	var offset = Vector2(130, 15) # Offset so the units don't look like they are kissing the floor
	summon_location_Vector2 = Vector2(offset.x, viewport_y-ground_y-offset.y)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Summon_1"):
		_on_q_pressed() 
	if Input.is_action_just_pressed("Summon_2"): 
		_on_w_pressed()
	if Input.is_action_just_pressed("Summon_3"): 
		_on_e_pressed()
	
	player_current_gold += 1
	command_panel.get_node("total_gold/Label").text = "Gold: " + str(player_current_gold)

func summon_slime():
	print("Trying to summon slime.")
	var slime_instance = slime_scene.instantiate()
	slime_instance.position = summon_location_Vector2
	add_child(slime_instance)

func _on_q_pressed() -> void:
	summon_slime()
	print("Summoned Slime with Q")

func _on_w_pressed() -> void:
	summon_slime()
	print("Summoned Slime with W")

func _on_e_pressed() -> void:
	summon_slime()
	print("Summoned Slime with E")
