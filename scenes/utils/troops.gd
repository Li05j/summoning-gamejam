# NAME: String						# Name of the troop
# COST: int							# Cost of troop in gold
# GOLD_DROP: int 					# Gold drop on death
# MOVE_SPEED: int 					# Movement speed
# MAX_HP: float 					# Max hp
# ATTACK_DMG: int 					# Atk damage
# ATTACK_SPD: float 				# Attack every ATTACK_SPD seconds, i.e. rate
# ATTACK_RANGE: int 				# Attack range
# ATTACK_FRAME: int					# The frame that attack should be resolved
# SPAWN_WAIT: float					# Spawn animation time in seconds
# SPEED_SCALE: float				# Animation rate - low rate means animation loop takes longer, 
									# i.e. also affects attack prep time
# PROJECTILE: false | Dictionary	# If false, troop does not shoot projectile,
									# otherwise, projectile stats are listed
	# PARABOLA:						# If projectile is a parabola, false means a straight line 
	# RATE:							# If parabola, defines how high it goes; if straight line then speed
	# Y_OFFSET:						# Where the projectile will shoot above ground
	# RANGE_MOD						# How much farther (multiplier) the projectile will last over the default range
# IS_AOE: bool						# If basic attack is AOE
# CC_IMMUNE: bool					# If immune to CC

extends Node

const MONSTER_T = {
	"GOBLIN": { 
		"NAME": "Goblin",
		"COST": 40,
		"GOLD_DROP": 13,
		"MOVE_SPEED": 120,
		"MAX_HP": 100,
		"ATTACK_DMG": 7,
		"ATTACK_SPD": 0.35,
		"ATTACK_RANGE": 35,
		"ATTACK_FRAME": 6,
		"SPAWN_WAIT": 0.8,
		"SPEED_SCALE": 2.5,
		"PROJECTILE": false,
		"IS_AOE": false,
		"CC_IMMUNE": false,
		"DESCRIPTION": "meow",
	},
	"SLIME": {
		"NAME": "Slime",
		"COST": 65,
		"GOLD_DROP": 21,
		"MOVE_SPEED": 60,
		"MAX_HP": 50,
		"ATTACK_DMG": 45,
		"ATTACK_SPD": 2.2,
		"ATTACK_RANGE": 160,
		"ATTACK_FRAME": 3,
		"SPAWN_WAIT": 0.8,
		"SPEED_SCALE": 0.5,
		"PROJECTILE": {
			"PARABOLA": true,
			"RATE": 2.0,
			"Y_OFFSET": 25,
			"RANGE_MOD": 1.0
		},
		"IS_AOE": false,
		"CC_IMMUNE": false,
		"DESCRIPTION": "meow",
	},
	"FIREWORM": {
		"NAME": "Fireworm",
		"COST": 100,
		"GOLD_DROP": 33,
		"MOVE_SPEED": 75,
		"MAX_HP": 225,
		"ATTACK_DMG": 12,
		"ATTACK_SPD": 2.4,
		"ATTACK_RANGE": 150,
		"ATTACK_FRAME": 10,
		"SPAWN_WAIT": 0.8,
		"SPEED_SCALE": 1.0,
		"PROJECTILE": {
			"PARABOLA": false,
			"RATE": 0.8,
			"Y_OFFSET": 25,
			"RANGE_MOD": 2.0
		},
		"IS_AOE": true,
		"CC_IMMUNE": false,
		"DESCRIPTION": "meow",
	},
	"GIANT": {
		"NAME": "Giant",
		"COST": 240,
		"GOLD_DROP": 80,
		"MOVE_SPEED": 25,
		"MAX_HP": 1500,
		"ATTACK_DMG": 15,
		"ATTACK_SPD": 3.0,
		"ATTACK_RANGE": 75,
		"ATTACK_FRAME": 3,
		"SPAWN_WAIT": 2.0,
		"SPEED_SCALE": 0.5,
		"PROJECTILE": false,
		"IS_AOE": true,
		"CC_IMMUNE": true,
		"DESCRIPTION": "meow",
	},
}
