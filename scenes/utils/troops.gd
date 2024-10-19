# NAME: String			# Name of the troop
# COST: int				# Cost of troop in gold
# GOLD_DROP: int 		# Gold drop on death
# MOVE_SPEED: int 		# Movement speed
# MAX_HP: float 		# Max hp
# ATTACK_DMG: int 		# Atk damage
# ATTACK_SPD: float 	# Attack every ATTACK_SPD seconds, i.e. rate
# ATTACK_RANGE: int 	# Attack range
# ATTACK_FRAME: int		# The frame that attack should be resolved
# SPAWN_WAIT: float	# Spawn animation time in seconds
## Animation rate - low rate means animation loop takes longer, i.e. also affects attack prep time
# SPEED_SCALE: float
# IS_AOE: bool			# If basic attack is AOE
# CC_IMMUNE: bool		# If immune to CC

extends Node

const MONSTER_T = {
	"SLIME": {
		"NAME": "Slime",
		"COST": 65,
		"GOLD_DROP": 22,
		"MOVE_SPEED": 60,
		"MAX_HP": 45,
		"ATTACK_DMG": 40,
		"ATTACK_SPD": 2.0,
		"ATTACK_RANGE": 150,
		"ATTACK_FRAME": 5,
		"SPAWN_WAIT": 0.8,
		"SPEED_SCALE": 0.75,
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
		"ATTACK_DMG": 8,
		"ATTACK_SPD": 0.4,
		"ATTACK_RANGE": 30,
		"ATTACK_FRAME": 6,
		"SPAWN_WAIT": 0.8,
		"SPEED_SCALE": 2.0,
		"IS_AOE": false,
		"CC_IMMUNE": false,
		"DESCRIPTION": "meow",
	},
	"GIANT": {
		"NAME": "Giant",
		"COST": 270,
		"GOLD_DROP": 90,
		"MOVE_SPEED": 25,
		"MAX_HP": 1050,
		"ATTACK_DMG": 15,
		"ATTACK_SPD": 3.5,
		"ATTACK_RANGE": 75,
		"ATTACK_FRAME": 3,
		"SPAWN_WAIT": 2.0,
		"SPEED_SCALE": 0.5,
		"IS_AOE": true,
		"CC_IMMUNE": true,
		"DESCRIPTION": "meow",
	}
}
