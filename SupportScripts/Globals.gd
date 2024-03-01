extends Node

var RANDOM_SEED = int(Time.get_unix_time_from_system() * 1000)

var CELL_SIZE = 64

var CELLS_DRILLED = {
}
var WALLS_BUILT = {
}

var ACTION_TIMEOUT = 30
var ACTION_TIMER = ActionTimer.new(ACTION_TIMEOUT)


