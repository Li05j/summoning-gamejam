extends Control
var slime_scene = preload("res://scenes/troops/slime.tscn") # Preload slime scene
var goblin_scene = preload("res://scenes/troops/goblin.tscn")
var giant_scene = preload("res://scenes/troops/giant.tscn")

@onready var good_tower = $VBoxContainer/Battlefield/Good_Tower
@onready var bad_tower = $VBoxContainer/Battlefield/Bad_Tower
@onready var tower_death_timer = $VBoxContainer/Battlefield/Tower_Death_Timer
@onready var Q_Button = $HBoxContainer/Q_Button
@onready var W_Button = $HBoxContainer/W_Button
@onready var E_Button = $HBoxContainer/E_Button
@onready var R_Button = $HBoxContainer/R_Button


var tower_to_destroy = null;

var battlefield;
var command_panel;

var friendly_summon_location_Vector2: Vector2;
var enemy_summon_location_Vector2: Vector2;

var player_current_gold = 100;
var q_cost = 50;
var w_cost = 30;
var e_cost = 200;
var r_cost = 100;

const TOWER_MAX = 1000;
var good_tower_health = TOWER_MAX;
var bad_tower_health = TOWER_MAX;

signal goodTowerHealthChange
signal badTowerHealthChange

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	battlefield = $VBoxContainer/Battlefield
	command_panel = $VBoxContainer/Command_Panel
	
	good_tower.play("vibe")
	bad_tower.play("vibe")
	
	var viewport_y = get_viewport_rect().size.y
	var ground_y = command_panel.get_global_rect().size.y

	var offset = Vector2(130, -5) # Offset so the units don't look like they are kissing the floor
	friendly_summon_location_Vector2 = Vector2(offset.x, viewport_y-ground_y-offset.y) # Determining summoning position
	enemy_summon_location_Vector2 = Vector2(975, viewport_y-ground_y-offset.y) # 975 is default enemy spawn point too lazy to make it a global const whatever
	
	update_costs()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Summon_1"):
		_on_q_pressed() 
	if Input.is_action_just_pressed("Summon_2"): 
		_on_w_pressed()
	if Input.is_action_just_pressed("Summon_3"): 
		_on_e_pressed()
	# Done for testing death
	if Input.is_action_just_pressed("Discount"):
		damageGoodTower(100)
		damageBadTower(200)
	if Input.is_action_just_pressed("Discount"): 
		_on_r_pressed()
	Q_Button.disabled = player_current_gold < q_cost
	W_Button.disabled = player_current_gold < w_cost
	E_Button.disabled = player_current_gold < e_cost
	R_Button.disabled = player_current_gold < r_cost
		
		
		
# Cancerous WET style here 🤦‍♂️
func damageGoodTower(damage: int) -> void:
	if good_tower_health - damage <= 0 and tower_to_destroy == null: # otherwise winner can be overrided
		tower_to_destroy = good_tower	
		good_tower.position.y = good_tower.position.y + 2.187 # fire is a bit off the ground
		good_tower.play("death")
		tower_death_timer.start()
	good_tower_health -= damage
	goodTowerHealthChange.emit()

func damageBadTower(damage: int) -> void:
	if bad_tower_health - damage <= 0 and tower_to_destroy == null:
		tower_to_destroy = bad_tower
		bad_tower.position.y = bad_tower.position.y + 2.187
		bad_tower.play("death")
		tower_death_timer.start()
	bad_tower_health -= damage
	badTowerHealthChange.emit()
	

func summon_friendly_slime():
	player_current_gold -= q_cost
	var slime_instance = slime_scene.instantiate()
	slime_instance.position = friendly_summon_location_Vector2
	get_node("Friend_Troop_Container").add_child(slime_instance)
	
func summon_friendly_goblin():
	player_current_gold -= w_cost
	var goblin_instance = goblin_scene.instantiate()
	goblin_instance.position = friendly_summon_location_Vector2
	get_node("Friend_Troop_Container").add_child(goblin_instance)

func summon_friendly_giant():
	player_current_gold -= e_cost
	var giant_instance = giant_scene.instantiate()
	giant_instance.position = friendly_summon_location_Vector2
	get_node("Friend_Troop_Container").add_child(giant_instance)
	
func summon_enemy_slime():
	var slime_instance = slime_scene.instantiate()
	slime_instance.set_enemy(enemy_summon_location_Vector2);
	get_node("Enemy_Troop_Container").add_child(slime_instance)
	
func summon_enemy_goblin():
	var goblin_instance = goblin_scene.instantiate()
	goblin_instance.set_enemy(enemy_summon_location_Vector2);
	get_node("Enemy_Troop_Container").add_child(goblin_instance)
		
func summon_enemy_giant():
	var giant_instance = goblin_scene.instantiate()
	giant_instance.set_enemy(enemy_summon_location_Vector2);
	get_node("Enemy_Troop_Container").add_child(giant_instance)
	
func r_purchase():
	player_current_gold -= r_cost
	q_cost = max(1, floor(q_cost * 0.95))
	w_cost = max(1, floor(w_cost * 0.95))
	e_cost = max(1, floor(e_cost * 0.95))
	r_cost = floor(r_cost * 1.05)
	update_costs()
	
func update_costs():
	command_panel.get_node("q_cost/Label").text = "Q Cost: " + str(q_cost)
	command_panel.get_node("w_cost/Label").text = "W Cost: " + str(w_cost)
	command_panel.get_node("e_cost/Label").text = "E Cost: " + str(e_cost)
	command_panel.get_node("r_cost/Label").text = "R Cost: " + str(r_cost)

func _on_q_pressed() -> void:
	if player_current_gold >= q_cost:
		summon_friendly_slime()

func _on_w_pressed() -> void:
	if player_current_gold >= w_cost:
		summon_friendly_goblin()

func _on_e_pressed() -> void:
	if player_current_gold >= e_cost:
		summon_friendly_giant()
		
func _on_r_pressed() -> void:
	if player_current_gold >= r_cost:
		r_purchase()

func _on_timer_timeout() -> void:
	player_current_gold += 20
	command_panel.get_node("total_gold/Label").text = "Gold: " + str(player_current_gold)

func _on_enemy_ai_react_time_timeout() -> void:
	summon_enemy_goblin()

func _on_tower_death_timer_timeout() -> void:
	tower_to_destroy.queue_free()
	if tower_to_destroy == bad_tower:
		get_tree().change_scene_to_file("res://scenes/menus/victory_scene.tscn")
	elif tower_to_destroy == good_tower:
		get_tree().change_scene_to_file("res://scenes/menus/defeat_scene.tscn")
