extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_node("Too Bad").text = "You LOSE! \nTime: " + str(GAME_STATE.final_time)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_exit_pressed() -> void:
	print("Exit Pressed")
	get_tree().quit()

func _on_new_game_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/game_menu/game_menu.tscn")
