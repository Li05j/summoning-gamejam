extends Control

var slime_scene = preload("res://scenes/troops/slime.tscn") # Preload slime scene
var goblin_scene = preload("res://scenes/troops/goblin.tscn")
var fireworm_scene = preload("res://scenes/troops/fireworm.tscn")
var giant_scene = preload("res://scenes/troops/giant.tscn")

@onready var friend_base = $VBoxScreenLayout/Battlefield/Friend_Base
@onready var enemy_base = $VBoxScreenLayout/Battlefield/Enemy_Base
@onready var base_burn_timer = $VBoxScreenLayout/Battlefield/Base_Burn_Timer

@onready var Q_Button = $HBoxButtonLayout/Q_Button
@onready var W_Button = $HBoxButtonLayout/W_Button
@onready var E_Button = $HBoxButtonLayout/E_Button
@onready var R_Button = $HBoxButtonLayout/R_Button
@onready var J_Button = $HBoxButtonLayout/J_Button
@onready var K_Button = $HBoxButtonLayout/K_Button

@onready var battlefield = $VBoxScreenLayout/Battlefield
@onready var command_panel = $VBoxScreenLayout/CommandPanel

@onready var battle_bgm = $BGM/Fight

var friendly_summon_location_Vector2: Vector2;
var enemy_summon_location_Vector2: Vector2;

var time: int = 0
var player_current_gold: int = GLOBAL_C.STARTING_GOLD;
var gold_step: int = 5

var q_cost: int = T.MONSTER_T.get("GOBLIN").get("COST")
var w_cost: int = T.MONSTER_T.get("SLIME").get("COST")
var e_cost: int = T.MONSTER_T.get("FIREWORM").get("COST")
var r_cost: int = T.MONSTER_T.get("GIANT").get("COST")

var j_cost: int = GLOBAL_C.LAB_COST
var k_cost: int = GLOBAL_C.GOLD_MINE_COST

# TODO: Add pause menu with retry, and also a more comprehensive help menu. Also refactor victory/defeat scene if I feel like it.
func _ready() -> void:
	# TODO: Should make an array of buttons/troops etc., so I can just iterate
	# Makes things easier and more abstracted, automatic
	var viewport_y = get_viewport_rect().size.y
	var ground_y = command_panel.get_global_rect().size.y

	# Determining summoning position
	var offset_y = -5
	friendly_summon_location_Vector2 = Vector2(GLOBAL_C.FRIENDLY_BASE_X, viewport_y-ground_y-offset_y)
	enemy_summon_location_Vector2 = Vector2(GLOBAL_C.ENEMY_BASE_X, viewport_y-ground_y-offset_y)
	
	update_gold_text()
	update_costs_text()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# can probably put button stuff in another script
	if Input.is_action_just_pressed("Summon_1"):
		_on_key_pressed("Summon_1") 
	if Input.is_action_just_pressed("Summon_2"): 
		_on_key_pressed("Summon_2")
	if Input.is_action_just_pressed("Summon_3"): 
		_on_key_pressed("Summon_3")
	if Input.is_action_just_pressed("Summon_4"): 
		_on_key_pressed("Summon_4")
		
	if Input.is_action_just_pressed("Lab_purchase"): 
		_on_key_pressed("Lab_purchase")
	if Input.is_action_just_pressed("Gold_Mine_purchase"): 
		_on_key_pressed("Gold_Mine_purchase")
	Q_Button.disabled = player_current_gold < q_cost
	W_Button.disabled = player_current_gold < w_cost
	E_Button.disabled = player_current_gold < e_cost
	R_Button.disabled = player_current_gold < r_cost
	
	J_Button.disabled = player_current_gold < j_cost
	K_Button.disabled = player_current_gold < k_cost
	
func summon_troop(troop: String, friend: bool):
	var troop_instance;
	match troop:
		"GOBLIN":
			troop_instance = goblin_scene.instantiate()
		"SLIME":
			troop_instance = slime_scene.instantiate()
		"FIREWORM":
			troop_instance = fireworm_scene.instantiate()
		"GIANT":
			troop_instance = giant_scene.instantiate()
		_:
			push_error("Invalid troop name: " + troop)
	
	if friend:
		troop_instance.position = friendly_summon_location_Vector2
		get_node("NonUI/Friend_Troop_Container").add_child(troop_instance)
	else:
		troop_instance.set_as_enemy(enemy_summon_location_Vector2)
		get_node("NonUI/Enemy_Troop_Container").add_child(troop_instance)
	
func damage_base(dmg: int, is_troop_friend: bool) -> void:
	if !is_troop_friend:
		if friend_base.get_node("base_hp_bar").take_dmg(dmg) and GAME_STATE.win == null:
			GAME_STATE.win = false
			base_burn_timer.start()
	else:
		if enemy_base.get_node("base_hp_bar").take_dmg(dmg) and GAME_STATE.win == null:
			GAME_STATE.win = true
			base_burn_timer.start()

func discount_purchase() -> void:
	player_current_gold -= j_cost
	q_cost = max(1, floor(q_cost * GLOBAL_C.LAB_DISCOUNT_RATE))
	w_cost = max(1, floor(w_cost * GLOBAL_C.LAB_DISCOUNT_RATE))
	e_cost = max(1, floor(e_cost * GLOBAL_C.LAB_DISCOUNT_RATE))
	r_cost = max(1, floor(r_cost * GLOBAL_C.LAB_DISCOUNT_RATE))
	
	j_cost = floor(j_cost * GLOBAL_C.LAB_COST_INCREASE_RATE)
	k_cost = floor(k_cost * GLOBAL_C.LAB_DISCOUNT_RATE)
	update_costs_text()
	
func passive_income_purchase() -> void:
	player_current_gold -= k_cost
	gold_step += 1
	k_cost = floor(k_cost * GLOBAL_C.GOLD_MINE_COST_INCREASE_RATE)
	update_costs_text()
	
func update_costs_text():
	command_panel.get_node("q_cost/Label").text = str(q_cost)
	command_panel.get_node("w_cost/Label").text = str(w_cost)
	command_panel.get_node("e_cost/Label").text = str(e_cost)
	command_panel.get_node("r_cost/Label").text = str(r_cost)
	command_panel.get_node("j_cost/Label").text = str(j_cost)
	command_panel.get_node("k_cost/Label").text = str(k_cost)
	
func update_gold_text():
	command_panel.get_node("total_gold/Label").text = "Gold: " + str(player_current_gold)

func _on_key_pressed(key: String) -> void:
	match key:
		"Summon_1":
			if player_current_gold >= q_cost:
				player_current_gold -= q_cost
				summon_troop("GOBLIN", true)
		"Summon_2":
			if player_current_gold >= w_cost:
				player_current_gold -= w_cost
				summon_troop("SLIME", true)
		"Summon_3":
			if player_current_gold >= e_cost:
				player_current_gold -= e_cost
				summon_troop("FIREWORM", true)
		"Summon_4":
			if player_current_gold >= r_cost:
				player_current_gold -= r_cost
				summon_troop("GIANT", true)
		"Lab_purchase":
			if player_current_gold >= j_cost:
				discount_purchase()
		"Gold_Mine_purchase":
			if player_current_gold >= k_cost:
				passive_income_purchase()
		_:
			return
	update_gold_text()

func _on_add_gold_timer_timeout() -> void:
	player_current_gold += gold_step
	time += 1
	update_gold_text()
	command_panel.get_node("game_time/Label").text = "Time: " + str(time)
	
func _on_base_burn_timer_timeout() -> void:
	GAME_STATE.final_time = time
	if GAME_STATE.win:
		get_tree().change_scene_to_file("res://scenes/menus/notice_menu/victory_scene.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/menus/notice_menu/defeat_scene.tscn")

func _on_fight_bgm_finished() -> void:
	battle_bgm.play()
