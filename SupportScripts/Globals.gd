extends Node

var RANDOM_SEED = int(Time.get_unix_time_from_system() * 1000)

var CELL_SIZE = 64

var CELLS_DRILLED = {}
var WALLS_BUILT = {}
var MINES_BUILT = {}

var ACTION_TIMEOUT = 30
var ACTION_TIMER = ActionTimer.new(ACTION_TIMEOUT)

var TANK_INVENTORY = Inventory.new(100)
var GLOBAL_INVENTORY = Inventory.new(100000)

var ORE_PER_NODE_DRILLED = 5
var ORE_COST_PER_MINE = 0

enum UNDERGROUND_RESOURCES {
	DIRT,
	COAL,
	COPPER,
	IRON,
	MAGNESIUM
}

