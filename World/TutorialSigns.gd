extends Marker2D

var tutorial_texture = load("res://assets/TutorialSigns.png")
# Called when the node enters the scene tree for the first time.
func _ready():
	create_sprites(0, 0, 2, 0)
	create_sprites(0, 1, 2, 250)
	create_sprites(0, 2, 2, 500)
	create_sprites(1, 1, 1, 750)
	create_sprites(1, 2, 1, 1000)
	create_sprites(1, 0, 2, 1250)


func create_sprites(row, col, stand, x_offset):
	var sign = Sprite2D.new()
	sign.texture = tutorial_texture
	sign.region_enabled = true
	sign.region_rect = Rect2(col * 128, row * 128, 128, 128)
	sign.position = Vector2(x_offset, -192)
	
	var legs = Sprite2D.new()
	legs.texture = tutorial_texture
	legs.region_enabled = true
	var legRow = 2
	var legCol = 0 + stand
	legs.region_rect = Rect2(legCol * 128, legRow * 128, 128, 128)
	legs.position = Vector2(x_offset, -64)
	
	add_child(sign)
	add_child(legs)
	#var sprite = Sprite2D.new()
	#sprite.texture = tutorial_texture
	# Set the sprite position on the screen
#	sprite.position = Vector2(0, -128)
	#sprite.region_enabled = true
	#sprite.region_rect = Rect2(128,0, 128,128)
	
	# Add the sprite as a child of the current node
	#add_child(sprite)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
