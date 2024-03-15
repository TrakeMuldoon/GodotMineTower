extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.TANK_INVENTORY.inventory_modified.connect(_on_inventory_modified)
	Globals.GLOBAL_INVENTORY.inventory_modified.connect(_on_inventory_modified)
	$WorldSeed.text = "World Seed:" + str(Globals.RANDOM_SEED)

# Called every frame. 'delta' is the elapsed time since the previous frame.
var counter = 0
func _process(delta):
	var most_recent_dict = Globals.ACTION_TIMER.GetMostRecent()
	$ActionTimerLabel.text = most_recent_dict["label"]
	$ActionTimerBar.value = most_recent_dict["progress"] * 100

func _on_backup_character_character_moved(pos):
	var scene = get_tree().get_current_scene()
	var tilemap = scene.get_node("WorldLevel").get_node("GroundMap")
	var posy = Vector2(pos.x, pos.y + 32)
	var l2m = tilemap.local_to_map(posy)
	l2m.y = l2m.y / 4
	l2m.x = l2m.x / 4
	
	var modPosition = Vector2((pos.x - 32)/4, (pos.y + 32) / 4)
	$PlayerLocation.text = "Player Location:\n" + str(pos) + "\n" + str(modPosition) + "\n" + str(l2m)  


var ore_tracker = {}
func _on_inventory_modified():
	$TankInventory.text = Globals.TANK_INVENTORY.HUD_printout()
	$WorldInventory.text = Globals.GLOBAL_INVENTORY.HUD_printout()
	var ore_list = Globals.GLOBAL_INVENTORY.get_ores()
	for ore in ore_list:
		var val = Globals.GLOBAL_INVENTORY.get_value(ore)
		if not ore in ore_tracker:
			var ore_sprite = get_ore_sprite(ore)
			$WorldInventoryGrid.add_child(ore_sprite)
			var label = Label.new()
			$WorldInventoryGrid.add_child(label)
			ore_tracker[ore] = label
		ore_tracker[ore].text = str(val) 


var ore_texture = load("res://assets/UndergroundTileset.png")
var ore_sprite_size = Vector2(16,16)
func get_ore_sprite(orename):
	var sprite_sheet_row = 0
	match orename:
		"COAL": sprite_sheet_row = 1
		"COPPER": sprite_sheet_row = 2
		"IRON": sprite_sheet_row = 3
		"MAGNESIUM": sprite_sheet_row = 4
		_: sprite_sheet_row = 0
	var sprite = TextureRect.new()
	var tex_subregion = AtlasTexture.new()
	tex_subregion.set_atlas(ore_texture)
	tex_subregion.set_region(Rect2(4 * 16, sprite_sheet_row * 16, 16, 16))
	sprite.texture = tex_subregion
	return sprite

func _on_tank_character_fuel_modified(fuel_percentage):
	$FuelTank.value = fuel_percentage * 100
