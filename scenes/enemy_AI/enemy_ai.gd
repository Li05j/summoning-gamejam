extends Node2D

@onready var master_timer = $MasterTimer

# This is shit, needs overhaul for style and scalability

enum AIState { ALLIN, AGGRESSIVE, BALANCED, CONSERVATIVE }

const MAX_STEP = 100 # Step for decision - when MAX_STEP, ai makes a new decision

var game_menu
var enemy_base_hp_bar

var timer_step: int # [0,100], when step > 100, AI will make a move, else, random gen step size

var enemy_current_gold: int = GLOBAL_C.STARTING_GOLD
var enemy_income: int = 4

var mode = AIState.AGGRESSIVE
var mode_changes = 0

var monster_troops: Dictionary = T.MONSTER_T
var action_weights: Dictionary # dictionary of summoning chances for each troop

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_menu = get_tree().root.get_node("GameMenu")
	enemy_base_hp_bar = game_menu.get_node("VBoxScreenLayout/Battlefield/Enemy_Base/base_hp_bar")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
# This looks ugly as fuck
func update_ai_behavior() -> AIState:
	if mode != AIState.ALLIN and enemy_base_hp_bar.get_as_ratio() < 0.66:
		enemy_current_gold += 100 + mode_changes * 5
		master_timer.stop()
		master_timer.start()
		return AIState.ALLIN
		
	if mode != AIState.ALLIN and enemy_base_hp_bar.get_as_ratio() < 0.33:
		enemy_current_gold += 200 + mode_changes * 15
		enemy_income += 1
		master_timer.stop()
		master_timer.start()
		return AIState.ALLIN

	var conserve_base_chance = 100
	var balanced_base_chance = 100
	var aggressive_base_chance = 75
	var allin_base_chance = 10
	
	if enemy_current_gold < 50:
		conserve_base_chance += 50
	elif enemy_current_gold < 200:
		conserve_base_chance += 50
		balanced_base_chance += 50
		aggressive_base_chance += 25
	elif enemy_current_gold < 400:
		balanced_base_chance += 50
		aggressive_base_chance += 50
		allin_base_chance += 15
	elif enemy_current_gold > 750:
		balanced_base_chance += 50
		aggressive_base_chance += 125
		allin_base_chance += 40
		
	if enemy_base_hp_bar.value == 100:
		conserve_base_chance += 50
		balanced_base_chance += 10	
	elif enemy_base_hp_bar.value < 75:
		balanced_base_chance += 75
		aggressive_base_chance += 30
		allin_base_chance += 15
	elif enemy_base_hp_bar.value < 50:
		balanced_base_chance += 75
		aggressive_base_chance += 75
		allin_base_chance += 60
	elif enemy_base_hp_bar.value < 25:
		conserve_base_chance = 0
		aggressive_base_chance += 75
		allin_base_chance += 100
		
	match mode:
		AIState.BALANCED:
			balanced_base_chance = 0
		AIState.AGGRESSIVE:
			aggressive_base_chance = 0
		AIState.ALLIN:
			allin_base_chance = 0
		
	var total_chance = conserve_base_chance + balanced_base_chance + aggressive_base_chance + allin_base_chance
	var random_state = randf_range(0, total_chance)
	if random_state < conserve_base_chance:
		return AIState.CONSERVATIVE
	elif random_state < conserve_base_chance + balanced_base_chance:
		return AIState.BALANCED
	elif random_state < conserve_base_chance + balanced_base_chance + aggressive_base_chance:
		return AIState.AGGRESSIVE
	else:
		return AIState.ALLIN
# The code above looks ugly as fuck
		
func perform_action() -> void:
	if (timer_step < MAX_STEP):
		return
	
	action_weights.clear()
	timer_step -= MAX_STEP

	var do_nothing_base_chance = 100
	
	for troop in monster_troops:
		var chance = 0
		action_weights[troop] = 0
		if enemy_current_gold > monster_troops[troop].get("COST", INF):
			chance += 100
		else:
			continue
		
		match mode:
			AIState.CONSERVATIVE:
				do_nothing_base_chance += 30
				if enemy_current_gold > monster_troops[troop].get("COST", INF) * 5:
					chance *= 2
				else:
					chance /= 5
			AIState.BALANCED:
				do_nothing_base_chance += 10
				if enemy_current_gold > monster_troops[troop].get("COST", INF) * 2.5:
					chance *= 2
				else:
					chance /= 5
			AIState.AGGRESSIVE:
				chance *= 1.25
			AIState.ALLIN:
				chance *= 2.0
				
		action_weights[troop] = chance
			
	print("performing action... mode " + str(mode))
	
	var total_weight = 0
	for key in action_weights:
		total_weight += action_weights[key]
	
	var rand_value = randf_range(0, total_weight + do_nothing_base_chance)
	var cumulative_weight = 0
	var the_chosen_one: String = ""
	for key in action_weights:
		cumulative_weight += action_weights[key]
		if rand_value <= cumulative_weight:
			the_chosen_one = key
			break
			
	if the_chosen_one == "":
		print("did nothing")
		return
	else:
		enemy_current_gold -= T.MONSTER_T.get(the_chosen_one).get("COST")
		game_menu.summon_troop(the_chosen_one, false)
		print("summoned " + the_chosen_one + ", gold: " + str(enemy_current_gold))
		
func allin_step_calc(r: float) -> int:
	var step = 10 + r * MAX_STEP
	return step

func aggresive_step_calc(r: float) -> int:
	var step = pow(r, 2) * MAX_STEP
	return step

func balanced_step_calc(r: float) -> int:
	var step = pow(r, 4) * MAX_STEP
	return step
	
func conserve_step_calc(r: float) -> int:
	var step = pow(r, 6) * MAX_STEP
	return step

func _on_gold_timer_timeout() -> void:
	enemy_current_gold += enemy_income

func _on_master_timer_timeout() -> void:
	var prev_mode = mode
	mode = update_ai_behavior()
	mode_changes += 1
	if mode_changes < 18:
		if (mode_changes + 1) % 4 == 0:
			enemy_income += 1
	else:
		if mode_changes % 5 == 0:
			enemy_income += 1
		
	if mode_changes % 6 == 0:
		enemy_current_gold += 100 + mode_changes * 10

	print("###################################")
	print("mode changed... " + str(prev_mode) + " -> " + str(mode))
	print("current gold " + str(enemy_current_gold))
	print("current income " + str(enemy_income))
	print("###################################")

func _on_decision_timer_timeout() -> void:
	var r = randf_range(0, 1)
	match mode:
		AIState.CONSERVATIVE:
			timer_step += conserve_step_calc(r)
			perform_action()
		AIState.BALANCED:
			timer_step += balanced_step_calc(r)
			perform_action()
		AIState.AGGRESSIVE:
			timer_step += aggresive_step_calc(r)
			perform_action()
		AIState.ALLIN:
			timer_step += allin_step_calc(r)
			perform_action()
			
