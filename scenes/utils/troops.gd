# NAME: String			# Name of the troop
# COST: int				# Cost of troop in gold
# GOLD_DROP: int 		# Gold drop on death
# MOVE_SPEED: int 		# Movement speed
# MAX_HP: float 		# Max hp
# ATTACK_DMG: int 		# Atk damage
# ATTACK_SPD: float 	# Attack every ATTACK_SPD seconds, i.e. rate
# ATTACK_RANGE: int 	# Attack range
# SPAWN_WAIT: float	# Spawn animation time in seconds
## Animation rate - low rate means animation loop takes longer, i.e. also affects attack prep time
# SPEED_SCALE: float
# IS_AOE: bool			# If basic attack is AOE
# CC_IMMUNE: bool		# If immune to CC

const MONSTER_T = {
	"SLIME": {
		"NAME": "Slime",
		"COST": 50,
		"GOLD_DROP": 16,
		"MOVE_SPEED": 60,
		"MAX_HP": 30,
		"ATTACK_DMG": 25,
		"ATTACK_SPD": 2.5,
		"ATTACK_RANGE": 150,
		"SPAWN_WAIT": 0.8,
		"SPEED_SCALE": 0.75,
		"IS_AOE": false,
		"CC_IMMUNE": false,
		"DESCRIPTION": "meow",
	},
	"GOBLIN": { 
		"NAME": "Goblin",
		"COST": 30,
		"GOLD_DROP": 10,
		"MOVE_SPEED": 100,
		"MAX_HP": 65,
		"ATTACK_DMG": 5,
		"ATTACK_SPD": 0.5,
		"ATTACK_RANGE": 30,
		"SPAWN_WAIT": 0.8,
		"SPEED_SCALE": 2.0,
		"IS_AOE": false,
		"CC_IMMUNE": false,
		"DESCRIPTION": "meow",
	},
	"GIANT": {
		"NAME": "Giant",
		"COST": 60,
		"GOLD_DROP": 43,
		"MOVE_SPEED": 125,
		"MAX_HP": 450,
		"ATTACK_DMG": 35,
		"ATTACK_SPD": 3.0,
		"ATTACK_RANGE": 75,
		"SPAWN_WAIT": 2.0,
		"SPEED_SCALE": 0.5,
		"IS_AOE": true,
		"CC_IMMUNE": true,
		"DESCRIPTION": "meow",
	}
}
