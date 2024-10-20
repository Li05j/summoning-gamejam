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
# IS_AOE: bool						# If basic attack is AOE
# CC_IMMUNE: bool					# If immune to CC

extends Node

const MONSTER_T = {
	"SLIME": {
		"NAME": "Slime",
		"COST": 65,
		"GOLD_DROP": 22,
		"MOVE_SPEED": 60,
		"MAX_HP": 1000,
		"ATTACK_DMG": 45,
		"ATTACK_SPD": 0.5,
		"ATTACK_RANGE": 660,
		"ATTACK_FRAME": 6,
		"SPAWN_WAIT": 0.8,
		"SPEED_SCALE": 1.0,
		"PROJECTILE": {
			"PARABOLA": true,
			"RATE": 2.5,
			"Y_OFFSET": 25,
		},
		"IS_AOE": false,
		"CC_IMMUNE": false,
		"DESCRIPTION": "meow",
	},
	"GOBLIN": { 
		"NAME": "Goblin",
		"COST": 40,
		"GOLD_DROP": 13,
		"MOVE_SPEED": 120,
		"MAX_HP": 100,
		"ATTACK_DMG": 9,
		"ATTACK_SPD": 0.4,
		"ATTACK_RANGE": 35,
		"ATTACK_FRAME": 6,
		"SPAWN_WAIT": 0.8,
		"SPEED_SCALE": 2.5,
		"PROJECTILE": false,
		"IS_AOE": false,
		"CC_IMMUNE": false,
		"DESCRIPTION": "meow",
	},
	"GIANT": {
		"NAME": "Giant",
		"COST": 240,
		"GOLD_DROP": 80,
		"MOVE_SPEED": 25,
		"MAX_HP": 1050,
		"ATTACK_DMG": 15,
		"ATTACK_SPD": 3.5,
		"ATTACK_RANGE": 75,
		"ATTACK_FRAME": 3,
		"SPAWN_WAIT": 2.0,
		"SPEED_SCALE": 0.5,
		"PROJECTILE": false,
		"IS_AOE": true,
		"CC_IMMUNE": true,
		"DESCRIPTION": "meow",
	}
}
