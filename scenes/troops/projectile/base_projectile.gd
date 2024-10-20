extends Area2D

class_name PROJECTILE

@onready var sprite = $AnimatedSprite2D

var is_friendly = true # default friendly projectile
var direction = 1 # right
var rate_wrt_range = 1.0
var real_range: int = 0
var velocity: Vector2

var is_parabola = false

var game_menu
var parent

# TODO: Need to let projectile live after unit death
func _ready() -> void:
	game_menu = get_tree().root.get_node("GameMenu")
	parent = get_parent()
	real_range = parent.TROOP_OBJ.get("ATTACK_RANGE")
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	if is_parabola:
		position += velocity * delta
		if position.y < 0:
			velocity.y += GLOBAL_C.GRAVITY_Y * delta * rate_wrt_range
		else:
			queue_free()
	else:
		position += velocity * delta
		if (is_friendly and position.x > real_range) or (!is_friendly and position.x < -real_range):
			queue_free()

func init(y_offset: int, range_mod: float = 1.0, parabola: bool = true, rate: float = 1.0, friendly: bool = true) -> void:
	if !friendly:
		is_friendly = false
		direction = -1
		sprite.flip_h = true
		
	real_range *= range_mod
	rate_wrt_range = rate
	
	if parabola:
		is_parabola = true
		velocity = Vector2(real_range / rate, -GLOBAL_C.GRAVITY_Y * rate)
	else:
		is_parabola = false
		velocity = Vector2(real_range * rate, 0)
		
	velocity.x *= direction
	position.y -= y_offset # lifting up from the ground

func resolve_contact() -> void:
	if !parent.TROOP_OBJ.get("IS_AOE"):
		queue_free()
	
func _on_body_entered(body):
	var layer = body.collision_layer
	
	# if building
	if layer == 8: 
		if parent.is_hitting_base:
			game_menu.damage_base(parent.TROOP_OBJ.get("ATTACK_DMG", -1), is_friendly)
			resolve_contact()
		else:
			return
	
	# if troop
	elif layer == 1:
		# TODO: do nothing on spawn
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
				resolve_contact()
