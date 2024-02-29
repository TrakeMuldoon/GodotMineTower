extends TileMap

var TILESET_ID = 0
var id = tile_set.get_source_id(TILESET_ID)

var EMPTY_TILE = Vector2(4,0)
var WALL_TILE = Vector2(5,0)
var DRILLED_TILE = Vector2(6,0)

var COAL_ROOT = Vector2(0,1)
var COPPER_ROOT = Vector2(0,2)
var IRON_ROOT = Vector2(0,3)
var MAG_ROOT = Vector2(0,4)

var EMPTY_TILE_V3 = Vector3(EMPTY_TILE.x, EMPTY_TILE.y,0)
var COAL_ROOT_V3 = Vector3(COAL_ROOT.x, COAL_ROOT.y, 0)
var COPPER_ROOT_V3 = Vector3(COPPER_ROOT.x, COPPER_ROOT.y, 0)
var IRON_ROOT_V3 = Vector3(IRON_ROOT.x, IRON_ROOT.y, 0)
var MAG_ROOT_V3 = Vector3(MAG_ROOT.x, MAG_ROOT.y, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func CreateInitialTileMap():
	for x in range(-50, 50):
		for y in range(0, 50):
			var munge_float = munge_three(x,y)
			
			var tile_location_and_alt = PickGroundType(munge_float)
			var tile_location = Vector2(tile_location_and_alt.x, tile_location_and_alt.y)
			var alt = tile_location_and_alt.z
			
			set_cell(0, Vector2(x, y), id, tile_location, alt)

func Can_Build_At(cell):
	var curr = get_cell_atlas_coords(0, cell)
	if (curr.x == 1 
			and curr.y > 0
			and curr.y < 5):
		return true
	else:
		return false

var ground_type = 0
func PickGroundType(a_float):
	if a_float < 0.86:
		return PickRandomDirt(a_float * 1.16)
	elif a_float < 0.95:
		return EMPTY_TILE_V3
	else:
		return PickOre((a_float - 0.95) * 20)

func PickOre(a_float):
	if a_float < 0.70:
		return COAL_ROOT_V3
	if a_float < 0.85:
		return COPPER_ROOT_V3
	if a_float < 0.95:
		return IRON_ROOT_V3
	else:
		return MAG_ROOT_V3
	
	
func PickRandomDirt(a_float):
	var pick_int = a_float *  16
	return Vector3(pick_int / 4, 0, int(pick_int) % 4)

func MarkX(cell):
	var deb_id = tile_set.get_source_id(1)
	set_cell(0, cell, deb_id, Vector2(11,1))

func BuildWall(cell):
	var orig_cell_atlas = get_cell_atlas_coords(0, cell)
	
	set_cell(0, cell, id, WALL_TILE)

func BuildMine(cell):
	var orig_cell_atlas = get_cell_atlas_coords(0, cell)
	var new_atlas_coords = Vector2(orig_cell_atlas.x + 1, orig_cell_atlas.y)
	set_cell(0, cell, id, new_atlas_coords)

func DigThrough(cell):
	var orig_cell_atlas = get_cell_atlas_coords(0, cell)
	
	var new_cell_atlas = Vector2(0,0)
	if orig_cell_atlas.y > 0:
		#we hit ore!!! Move the Tile over by 1, which is the marker for "drilled ore"
		new_cell_atlas.x = orig_cell_atlas.x + 1
		new_cell_atlas.y = orig_cell_atlas.y
	else:
		new_cell_atlas = DRILLED_TILE
	set_cell(0, cell, id, new_cell_atlas)

# This is a function I found on the internet to take two coords and turn them
# into a pseudorandom number, the only important thing for me being that there
# 1. No visible patterns
# 2. neighbouring cells have very different values
# 3. Completely reproducible. 
func munge_three(x, y):
	#/* mix around the bits in x: */
	x = x * 3266489917 + Globals.RANDOM_SEED
	x = (x << 17) | (x >> 15)

	  #/* mix around the bits in y and mix those into x: */
	x += y * 3266489917;

	#/* Give x a good stir: */
	x *= 668265263;
	x ^= x >> 15;
	x *= 2246822519;
	x ^= x >> 13;
	x *= 3266489917;
	x ^= x >> 16;

	#/* trim the result and scale it to a float in [0,1): */
	var ret = (x & 0x00ffffff)
	ret *= (1.0 / 0x1000000)
	if ret < 0:
		assert(false)
	return ret
	#return x

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
