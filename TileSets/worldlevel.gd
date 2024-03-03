extends Node2D

signal found_ore

# Called when the node enters the scene tree for the first time.
func _ready():
	$GroundMap.CreateInitialTileMap()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_player_new_cell_entered():
	$GroundMap.DigThrough(Globals.MOST_RECENT_CELL_ENTERED)


func _on_backup_character_drilled(cell):
	$GroundMap.DigThrough(cell)


func _on_backup_character_build_wall(cell):
	$GroundMap.BuildWall(cell)


func _on_tank_character_mark_my_cell(cell):
	$GroundMap.MarkX(cell)


func _on_tank_character_build_mine(cell):
	$GroundMap.BuildMine(cell)


func _on_ground_map_found_ore(ore_num):
	found_ore.emit(Globals.UNDERGROUND_RESOURCES.keys()[ore_num])
