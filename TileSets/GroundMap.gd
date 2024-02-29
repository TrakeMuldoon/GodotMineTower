extends TileMap

var TILESET_ID = 0
var id = tile_set.get_source_id(TILESET_ID)
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func CreateInitialTileMap():
	for x in range(-50, 50):
		for y in range(0, 50):
			var munge_float = munge_three(x,y)
			
			var tile_location = PickGroundType(munge_float)

			set_cell(0
					, Vector2(x, y)
					, id
					, Vector2(tile_location.x, tile_location.y)
					, tile_location.z)
var ground_type = 0
func PickGroundType(a_float):
	#return Vector3(1, 1, 0)
	if a_float < 0.86:
		return PickRandomDirt(a_float * 1.25)
	elif a_float < 0.95:
		return Vector3(4,2,0)
	else:
		return PickOre((a_float - 0.95) * 20)

func PickOre(a_float):
	var pick_int = int(a_float * 100)
	return Vector3(pick_int / 25, 1, 0)
	
func PickRandomDirt(a_float):
	var pick_int = a_float *  16
	return Vector3(pick_int / 4, 0, int(pick_int) % 4)

func BuildWall(cell):
	var orig_cell_atlas = get_cell_atlas_coords(0, cell)
	if orig_cell_atlas.y == 0:
		return
	
	var wall_atlas_coords = Vector2(0,3)
	set_cell(0, cell, id, wall_atlas_coords)

func DigThrough(cell):
	var orig_cell_atlas = get_cell_atlas_coords(0, cell)
	
	var new_atlas_coords = Vector2(5, 2)
	if orig_cell_atlas.y == 1:
		#we hit ore!!!
		new_atlas_coords.x = orig_cell_atlas.x + 4
		new_atlas_coords.y = orig_cell_atlas.y

	set_cell(0, cell, id, new_atlas_coords)

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
