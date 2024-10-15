extends Node2D

# This is shit, needs overhaul for style and scalability

enum AIState { ALLIN, AGGRESSIVE, BALANCED, CONSERVATIVE }

const MAX_STEP = 100

var game_menu
var enemy_base_hp_bar

var timer_step: int # [0,100], when step > 100, AI will make a move, else, random gen step size

var enemy_current_gold = GLOBAL_C.STARTING_GOLD
var enemy_income = 4

var mode = AIState.CONSERVATIVE;
var mode_changes = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_menu = get_tree().root.get_node("GameMenu")
	enemy_base_hp_bar = game_menu.get_node("VBoxScreenLayout/Battlefield/Enemy_Base/base_hp_bar")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func update_ai_behavior() -> AIState:
	if mode != AIState.ALLIN and enemy_base_hp_bar.get_as_ratio() < 0.33:
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
		balanced_base_chance += 50
		aggressive_base_chance += 25
		allin_base_chance += 15
	elif enemy_base_hp_bar.value < 50:
		balanced_base_chance += 75
		aggressive_base_chance += 40
		allin_base_chance += 40
		
	match mode:
		AIState.BALANCED:
			balanced_base_chance = 0
		AIState.AGGRESSIVE:
			aggressive_base_chance = 0
		AIState.ALLIN:
			allin_base_chance = 0
		
	var total_chance = conserve_base_chance + balanced_base_chance + aggressive_base_chance + allin_base_chance
	var random_state = randf_range(0, total_chance) # 0 to 99
	if random_state < conserve_base_chance:
		return AIState.CONSERVATIVE
	elif random_state < conserve_base_chance + balanced_base_chance:
		return AIState.BALANCED
	elif random_state < conserve_base_chance + balanced_base_chance + aggressive_base_chance:
		return AIState.AGGRESSIVE
	else:
		return AIState.ALLIN
		
func perform_action() -> void:
	if (timer_step < MAX_STEP):
		return
	
	timer_step -= MAX_STEP
	var slime_base_chance = 100
	var goblin_base_chance = 100
	var giant_base_chance = 100
	var do_nothing_base_chance = 100
	
	if enemy_current_gold < MONSTER_T.GIANT.COST:
		giant_base_chance = 0	
	if enemy_current_gold < MONSTER_T.GOBLIN.COST:
		goblin_base_chance = 0
	if enemy_current_gold < MONSTER_T.SLIME.COST:
		slime_base_chance = 0
		
	match mode:
		AIState.CONSERVATIVE:
			do_nothing_base_chance *= 2
			if enemy_current_gold > MONSTER_T.GIANT.COST * 3:
				giant_base_chance *= 2
			else:
				giant_base_chance /= 5
			if enemy_current_gold > MONSTER_T.GOBLIN.COST * 10:
				goblin_base_chance *= 2
			else:
				goblin_base_chance /= 5
			if enemy_current_gold > MONSTER_T.SLIME.COST * 7:
				slime_base_chance *= 2
			else:
				slime_base_chance /= 5
		AIState.BALANCED:
			do_nothing_base_chance * 2
			if enemy_current_gold > MONSTER_T.GIANT.COST * 2:
				giant_base_chance *= 2
			else:
				giant_base_chance /= 3
			if enemy_current_gold > MONSTER_T.GOBLIN.COST * 5:
				goblin_base_chance *= 2
			else:
				goblin_base_chance /= 3
			if enemy_current_gold > MONSTER_T.SLIME.COST * 4:
				slime_base_chance *= 2
			else:
				slime_base_chance /= 3
		AIState.AGGRESSIVE:
			do_nothing_base_chance *= 1
		AIState.ALLIN:
			do_nothing_base_chance /= 2
			
	print("performing action... mode " + str(mode))
			
	var total_chance = giant_base_chance + goblin_base_chance + slime_base_chance + do_nothing_base_chance
	var random_state = randf_range(0, total_chance) # 0 to 99
	if random_state < slime_base_chance:
		enemy_current_gold -= MONSTER_T.SLIME.COST
		game_menu.summon_troop(game_menu.slime_scene, false)
	elif random_state < slime_base_chance + goblin_base_chance:
		enemy_current_gold -= MONSTER_T.GOBLIN.COST
		game_menu.summon_troop(game_menu.goblin_scene, false)
	elif random_state < slime_base_chance + goblin_base_chance + giant_base_chance:
		enemy_current_gold -= MONSTER_T.GIANT.COST
		game_menu.summon_troop(game_menu.giant_scene, false)
	else:
		print("did nothing")
		
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
	mode = update_ai_behavior()
	mode_changes += 1
	if (mode_changes == 2):
		enemy_income += 1
	if (mode_changes == 5):
		enemy_income += 1
	if (mode_changes == 8):
		enemy_income += 1
	print("current mode " + str(mode))
	print("current gold " + str(enemy_current_gold))

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
			
