extends Control

var slime_scene = preload("res://scenes/troops/slime.tscn") # Preload slime scene
var goblin_scene = preload("res://scenes/troops/goblin.tscn")
var giant_scene = preload("res://scenes/troops/giant.tscn")

@onready var friend_base = $VBoxScreenLayout/Battlefield/Friend_Base
@onready var enemy_base = $VBoxScreenLayout/Battlefield/Enemy_Base
@onready var base_burn_timer = $VBoxScreenLayout/Battlefield/Base_Burn_Timer

@onready var Q_Button = $HBoxButtonLayout/Q_Button
@onready var W_Button = $HBoxButtonLayout/W_Button
@onready var E_Button = $HBoxButtonLayout/E_Button
@onready var R_Button = $HBoxButtonLayout/R_Button

var win = null;

var battlefield;
var command_panel;

var friendly_summon_location_Vector2: Vector2;
var enemy_summon_location_Vector2: Vector2;

var time = 0
var player_current_gold = GLOBAL_C.STARTING_GOLD;
var q_cost = MONSTER_T.SLIME.COST
var w_cost = MONSTER_T.GOBLIN.COST
var e_cost = MONSTER_T.GIANT.COST
var r_cost = GLOBAL_C.LAB_COST

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	battlefield = $VBoxScreenLayout/Battlefield
	command_panel = $VBoxScreenLayout/CommandPanel
	
	var viewport_y = get_viewport_rect().size.y
	var ground_y = command_panel.get_global_rect().size.y

	# Determining summoning position
	var offset_y = -5
	friendly_summon_location_Vector2 = Vector2(GLOBAL_C.FRIENDLY_BASE_X, viewport_y-ground_y-offset_y)
	enemy_summon_location_Vector2 = Vector2(GLOBAL_C.ENEMY_BASE_X, viewport_y-ground_y-offset_y)
	
	update_costs()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Summon_1"):
		_on_q_pressed() 
	if Input.is_action_just_pressed("Summon_2"): 
		_on_w_pressed()
	if Input.is_action_just_pressed("Summon_3"): 
		_on_e_pressed()
	if Input.is_action_just_pressed("Discount"): 
		_on_r_pressed()
	Q_Button.disabled = player_current_gold < q_cost
	W_Button.disabled = player_current_gold < w_cost
	E_Button.disabled = player_current_gold < e_cost
	R_Button.disabled = player_current_gold < r_cost
	
func summon_troop(scene, friend: bool):
	var troop_instance = scene.instantiate()
	if friend:
		troop_instance.position = friendly_summon_location_Vector2
		get_node("NonUI/Friend_Troop_Container").add_child(troop_instance)
	else:
		troop_instance.set_as_enemy(enemy_summon_location_Vector2)
		get_node("NonUI/Enemy_Troop_Container").add_child(troop_instance)
	
func damage_base(dmg: int, is_troop_friend: bool) -> void:
	if !is_troop_friend:
		if friend_base.get_node("base_hp_bar").take_dmg(dmg) and win == null:
			win = false
			base_burn_timer.start()
	else:
		if enemy_base.get_node("base_hp_bar").take_dmg(dmg) and win == null:
			win = true
			base_burn_timer.start()

func r_purchase() -> void:
	player_current_gold -= r_cost
	q_cost = max(1, floor(q_cost * 0.96))
	w_cost = max(1, floor(w_cost * 0.96))
	e_cost = max(1, floor(e_cost * 0.96))
	r_cost = floor(r_cost * 1.1)
	update_costs()
	
func update_costs():
	command_panel.get_node("q_cost/Label").text = "Q Cost: " + str(q_cost)
	command_panel.get_node("w_cost/Label").text = "W Cost: " + str(w_cost)
	command_panel.get_node("e_cost/Label").text = "E Cost: " + str(e_cost)
	command_panel.get_node("r_cost/Label").text = "R Cost: " + str(r_cost)

func _on_q_pressed() -> void:
	if player_current_gold >= q_cost:
		player_current_gold -= q_cost
		summon_troop(slime_scene, true)

func _on_w_pressed() -> void:
	if player_current_gold >= w_cost:
		player_current_gold -= w_cost
		summon_troop(goblin_scene, true)

func _on_e_pressed() -> void:
	if player_current_gold >= e_cost:
		player_current_gold -= e_cost
		summon_troop(giant_scene, true)
		
func _on_r_pressed() -> void:
	if player_current_gold >= r_cost:
		r_purchase()

func _on_add_gold_timer_timeout() -> void:
	player_current_gold += 5
	time += 1
	command_panel.get_node("total_gold/Label").text = "Gold: " + str(player_current_gold)
	command_panel.get_node("game_time/Label").text = "Time: " + str(time)
	
func _on_base_burn_timer_timeout() -> void:
	if win:
		get_tree().change_scene_to_file("res://scenes/menus/notice_menu/victory_scene.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/menus/notice_menu/defeat_scene.tscn")
