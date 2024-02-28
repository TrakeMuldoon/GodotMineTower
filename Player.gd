extends CharacterBody2D

@export var SPEED = 400 # How fast the player will move (pixels/sec).
signal new_cell_entered

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#activate(delta):
	pass	

func activate(delta):
	if visible:
		if (Input.is_action_pressed("go_right")
				|| Input.is_action_pressed("go_left")
				|| Input.is_action_pressed("go_down")
				|| Input.is_action_pressed("go_up")):
			set_motion(delta)

func set_motion(delta):
	#Determine what action is being taken
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("go_right"):
		velocity.x += 1
	if Input.is_action_pressed("go_left"):
		velocity.x -= 1
	if Input.is_action_pressed("go_down"):
		velocity.y += 1
	if Input.is_action_pressed("go_up"):
		velocity.y -= 1
	
	# Animation Stuff
	if velocity.length() > 0:
		velocity = velocity.normalized() * SPEED
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
	
	if velocity.x != 0:
		$AnimatedSprite2D.flip_h = velocity.x < 0
	
	position += velocity * delta
	Globals.PlayerWorldPosition += velocity * delta
	
	var worldPos = Globals.PlayerWorldPosition
	var cell = Vector2(int(worldPos.x / Globals.CELL_SIZE)
						, int(worldPos.y / Globals.CELL_SIZE))
	
	if not Globals.CELLS_VISITED.has(cell):
		Globals.CELLS_VISITED[cell] = null
		Globals.MOST_RECENT_CELL_ENTERED = cell
		queue_redraw()
		new_cell_entered.emit()
	
	#Update Labels
	$PlayerPosition.text = str(position)
	$WorldPosition.text = str(Globals.PlayerWorldPosition)

func _draw():
	#bg_draw_path()
	var len = Globals.CELLS_VISITED.size()
	$PathCounter.text = str(len)
	bg_draw_dots()

func bg_draw_dots():
	for c in Globals.CELLS_VISITED:
		draw_circle(_mult_vect2(c)
							, 5
							, Color.CORAL)

func _mult_vect2(cell):
	var sz = Globals.CELL_SIZE
	return Vector2((cell.x * sz) - sz/2
					, (cell.y * sz) - sz/2)
		

