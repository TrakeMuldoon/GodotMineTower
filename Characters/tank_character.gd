extends CharacterBody2D

@export var Speed : float = 300.0
@export var Jump_Velocity : float = -300.0
@export var Floor_Jump_Velocity : float = -500.0
signal character_moved
signal drilled
signal build_wall
signal mark_my_cell
signal build_mine
signal inventory_modified

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var tilemap

var ACTION_TIMER = Globals.ACTION_TIMER

func _ready():
	tilemap = get_tree().get_current_scene().get_node("WorldLevel").get_node("GroundMap")

func _physics_process(delta):
	if Input.is_action_pressed("Return"):
		ACTION_TIMER.ExecOnElapsed("Reset", ResetLocation)
	else:
		ACTION_TIMER.Reset("Reset")
	
	if Input.is_action_just_pressed("Mark"):
		var cell = Get_My_Cell()
		mark_my_cell.emit(cell)
	
	if Input.is_action_pressed("Mine") and is_on_floor():
		ACTION_TIMER.ExecOnElapsed("BuildMine", Build_Mine_Maybe)
	else:
		ACTION_TIMER.Reset("BuildMine")
	
	if Input.is_action_just_pressed("Wall") and is_on_floor():
		Build_Wall_Maybe()
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("go_up"):
		if is_on_floor(): # and is_on_floor():
			velocity.y = Floor_Jump_Velocity
		else:
			velocity.y = Jump_Velocity

	if Input.is_action_pressed("go_down") and is_on_floor():
		ACTION_TIMER.ExecOnElapsed("DrillDown", Drill_Down)
	else:
		ACTION_TIMER.Reset("DrillDown")
	
	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_axis("go_left", "go_right")
	
	if direction:
		if is_on_wall() and is_on_floor():
			if ACTION_TIMER.CounterElapsed("DrillSide"):
				Drill_Side(direction)
				ACTION_TIMER.Reset("DrillSide")
			else:
				ACTION_TIMER.Increment("DrillSide")
		else:
			ACTION_TIMER.Reset("DrillSide")
		velocity.x = direction * Speed

		if velocity.x < 0:
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false
	else:
		ACTION_TIMER.Reset("DrillSide")
		velocity.x = move_toward(velocity.x, 0, Speed)

	move_and_slide()

	character_moved.emit(position)

func Build_Mine_Maybe():
	var my_cell = Get_My_Cell()
	if(tilemap.Can_Build_At(my_cell)):
		Build_Mine(my_cell)

func Build_Mine(my_cell):
	build_mine.emit(my_cell)

func Get_My_Cell():
	var pos = $MarkPos.global_position
	var l2m = tilemap.local_to_map(pos)
	if l2m.y < 0:
		l2m.y -= 4
	if l2m.x < 0:
		l2m.x -= 4
	l2m.y = l2m.y / 4
	l2m.x = l2m.x / 4
	return l2m

func Build_Wall_Maybe():
	if $Headroom.has_overlapping_bodies():
		return

	var my_loc = Get_My_Cell()
	
	position.y -= 64 # move me out of the way
	velocity.y = Jump_Velocity * 0.1
	
	build_wall.emit(my_loc)

func Drill_Down():
	velocity.y = Jump_Velocity * 0.1
	var my_loc = Get_My_Cell()
	var drill_loc = Vector2(my_loc.x, my_loc.y + 1)
	drilled.emit(drill_loc)

func Drill_Side(direction):
	velocity.y = Jump_Velocity * 0.1
	var my_loc = Get_My_Cell()
	var drill_loc = Vector2(my_loc.x + (direction), my_loc.y)
	drilled.emit(drill_loc)
	

func _on_world_level_found_ore(ore_name):
	Globals.TANK_INVENTORY.add_to_inventory(ore_name, Globals.ORE_PER_NODE_DRILLED)
	

func ResetLocation():
	Globals.TANK_INVENTORY.clear_inventory()
	position = Vector2.ZERO
	var mt = MovingText.new()
	mt.text = "Inventory Wiped"
	add_child(mt)
	mt.go_to_it(1, 50)
