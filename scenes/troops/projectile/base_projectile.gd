extends Area2D

class_name PROJECTILE

var is_friendly = true # default friendly projectile
var direction = 1 # right
var rate_wrt_range = 1.0
var velocity: Vector2

var is_parabola = false

var game_menu
var parent

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_menu = get_tree().root.get_node("GameMenu")
	parent = get_parent()

func _physics_process(delta: float) -> void:
	if is_parabola:
		position += velocity * delta
		if position.y < 0:
			velocity.y += GLOBAL_C.GRAVITY_Y * delta * rate_wrt_range
		else:
			free_projectile()
	else:
		if position.x > parent.TROOP_OBJ.get("ATTACK_RANGE"):
			free_projectile()

func init(y_offset: int, parabola: bool = true, rate: float = 1.0, friendly: bool = true) -> void:
	if !friendly:
		is_friendly = false
		direction = -1
		
	rate_wrt_range = rate
	
	if parabola:
		is_parabola = true
		velocity = Vector2(parent.TROOP_OBJ.get("ATTACK_RANGE") / (rate * 2), -GLOBAL_C.GRAVITY_Y * rate)
	else:
		is_parabola = false
		velocity = Vector2(parent.TROOP_OBJ.get("ATTACK_RANGE") / (rate * 2), 0)
		
	velocity.x *= direction
	position.y -= y_offset # lifting up from the ground

func free_projectile() -> void:
	queue_free()
	
func _on_body_entered(body):
	var layer = body.collision_layer
	
	# if building
	if layer == 8: 
		if parent.is_hitting_base:
			game_menu.damage_base(parent.TROOP_OBJ.get("ATTACK_DMG", -1), is_friendly)
			free_projectile()
		else:
			return
	
	# if troop
	elif layer == 1:
		if body.is_friendly == parent.is_friendly or body.is_dead: # do nothing
			return
		
		var target_troop_container
		if !is_friendly:
			target_troop_container = game_menu.get_node("NonUI/Friend_Troop_Container")
		else:
			target_troop_container = game_menu.get_node("NonUI/Enemy_Troop_Container")

		# TODO: Apparently we can use groups for this?
		for child in target_troop_container.get_children():
			if body == child:
				body.take_dmg(parent.TROOP_OBJ.get("ATTACK_DMG", -1))
				free_projectile()
