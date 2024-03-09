extends CharacterBody2D

#Drive Speed
@export var Speed : float = 300.0

#Jumping
@export var Boost_Velocity : float = -300.0
@export var Floor_Boost_Velocity : float = -500.0
@export var Max_Boost_Velocity : float = -800.0

#Fuel
@export var StartFuelTankSize : int = 100
var FuelTankSize = StartFuelTankSize
var fuel = FuelTankSize
var fuel_decrease = 5

var reset_position = Vector2.ZERO

var dropped_item: PackedScene = preload("res://SupportScripts/dropped_item.tscn")

signal character_moved
signal drilled
signal build_wall
signal mark_my_cell
signal build_mine
signal inventory_modified
signal fuel_modified

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var tilemap

var ACTION_TIMER = Globals.ACTION_TIMER

func _ready():
	tilemap = get_tree().get_current_scene().get_node("WorldLevel").get_node("GroundMap")

func _physics_process(delta):
	if Input.is_action_pressed("Return"):
		ACTION_TIMER.ExecOnElapsed("Reset", ResetLocationAndDropInventory)
	else:
		ACTION_TIMER.Reset("Reset")
	
	if Input.is_action_just_pressed("Mark"):
		var cell = Get_My_Cell()
		mark_my_cell.emit(cell)
	
	if Input.is_action_pressed("Mine") and is_on_floor():
		ACTION_TIMER.ExecOnElapsed("BuildMine", Build_Mine_Maybe)
	else:
		ACTION_TIMER.Reset("BuildMine")
	
	if Input.is_action_pressed("Wall") and is_on_floor():
		ACTION_TIMER.ExecOnElapsed("Wall", Build_Wall_Maybe)
	else:
		ACTION_TIMER.Reset("Wall")
		
	# Handle Gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("go_up"):
		Jump()

	if Input.is_action_pressed("go_down") and is_on_floor():
		ACTION_TIMER.ExecOnElapsed("DrillDown", Drill_Down)
	else:
		ACTION_TIMER.Reset("DrillDown")
	
	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_axis("go_left", "go_right")
	
	#TODO: Split moving and drilling into separate code chunks.
	# move actionss up top
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


func Jump():
	if fuel < fuel_decrease:
		return
	if is_on_floor(): # and is_on_floor():
		velocity.y = Floor_Boost_Velocity
	else:
		velocity.y = Boost_Velocity
	if velocity.y < Max_Boost_Velocity:
		velocity.y = Max_Boost_Velocity
	else:
		fuel -= fuel_decrease
		var fuel_percent = float(fuel) / FuelTankSize
		fuel_modified.emit(fuel_percent)
		

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
	
	build_wall.emit(my_loc)

func Drill_Down():
	velocity.y = Boost_Velocity * 0.1
	var my_loc = Get_My_Cell()
	var drill_loc = Vector2(my_loc.x, my_loc.y + 1)
	drilled.emit(drill_loc)

func Drill_Side(direction):
	velocity.y = Boost_Velocity * 0.1
	var my_loc = Get_My_Cell()
	var drill_loc = Vector2(my_loc.x + (direction), my_loc.y)
	drilled.emit(drill_loc)

func _on_world_level_found_ore(ore_name):
	Globals.TANK_INVENTORY.add_to_inventory(ore_name, Globals.ORE_PER_NODE_DRILLED)
	
func ResetLocationAndDropInventory():
	var original_position = position
	position = reset_position
	
	var inventory = Globals.TANK_INVENTORY.clear_inventory()
	var curr_place = Vector2(original_position.x, original_position.y + 28)
	for ore in inventory:
		var amount = inventory[ore]
		while amount > 0:
			var pile = 50 if amount > 50 else amount
			amount -= 50
			curr_place = Vector2(curr_place.x + 8, curr_place.y - 8)
			create_ore_pile(ore, pile, curr_place)

	$MovingNotifier.EnqueueMessage("Inventory Dropped")

func create_ore_pile(ore_name, amount, location):
	var item = dropped_item.instantiate()
	item.SetVals(ore_name, amount)
	item.position = location
	get_parent().add_child(item)
	item.pickup_attempt.connect(ore_pile_entered)
	
func ore_pile_entered(a, b):
	var zero = 12 - 12
	var msg = "Grabbed " + str(b) + " " + str(a) + "s"
	$MovingNotifier.EnqueueMessage(msg)

func _on_gas_station_fill_gastank():
	fuel = FuelTankSize
	var fuel_percent = float(fuel) / FuelTankSize
	fuel_modified.emit(fuel_percent)
	$MovingNotifier.EnqueueMessage("Fueeled up!")
