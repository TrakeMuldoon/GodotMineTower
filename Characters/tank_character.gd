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

var reset_position = Vector2(1500, 0)

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
		ACTION_TIMER.ExecOnElapsed("Teleport", ResetLocationAndDropInventory)
	else:
		ACTION_TIMER.Reset("Teleport")
	
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
	
	if Input.is_action_just_pressed("Inventory"):
		ShowPlayerInventory()
	
	if Input.is_action_just_pressed("RingOfDebug"):
		ShowRingOfDebug()
	
	#TODO: Split moving and drilling into separate code chunks.
	# move actionss up top
	if direction:
		#Drill Related Stuff
		if is_on_wall() and is_on_floor():
			if ACTION_TIMER.CounterElapsed("DrillSide"):
				Drill_Side(direction)
				ACTION_TIMER.Reset("DrillSide")
			else:
				ACTION_TIMER.Increment("DrillSide")
		else:
			ACTION_TIMER.Reset("DrillSide")
			
		#Movement related stuff
		velocity.x = direction * Speed

		if velocity.x < 0:
			$AnimatedTank.flip_h = true
		else:
			$AnimatedTank.flip_h = false
	else:
		ACTION_TIMER.Reset("DrillSide")
		velocity.x = move_toward(velocity.x, 0, Speed)

	move_and_slide()

	character_moved.emit(position)

func ShowPlayerInventory():
	var my_popup = Popup.new()
	my_popup.title = "huh? wat?"
	my_popup.unresizable = false
	my_popup.size = Vector2i(200, 500)
	my_popup.borderless = false
	add_child(my_popup)
	my_popup.popup_centered()

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
		return # Can't move up, so can't build
		
	var my_loc = Get_My_Cell() # Find position wall should be
	position.y -= 64 # move me out of the way
	build_wall.emit(my_loc) # Tell wall to be built

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
	var inv = Globals.TANK_INVENTORY
	var cant_fit = inv.add_to_inventory(ore_name, Globals.ORE_PER_NODE_DRILLED)
	if cant_fit > 0:
		create_ore_pile(ore_name, cant_fit, position + ore_drop_offset)

func ResetLocationAndDropInventory():
	var my_cell = Get_My_Cell()

	var old_pos = position
	position = reset_position

	var the_x = old_pos.x / 64 if old_pos.x > 0 else (old_pos.x / 64) - 1
	var the_y = (old_pos.y / 64) + 1 if old_pos.y > 0 else (old_pos.y / 64)
	
	the_x = float(int(the_x) * 64)
	the_y = float(int(the_y) * 64)
	var m2l = Vector2(the_x, the_y)
	
	call_deferred("DropMyInventoryIntoPiles", m2l + ore_drop_offset)


func DropMyInventoryIntoPiles(drop_pos):
	var inventory = Globals.TANK_INVENTORY.clear_inventory()
	
	DropInventoryIntoPiles(inventory, drop_pos)
	$MovingNotifier.EnqueueMessage("Inventory Dropped")

func DropInventoryIntoPiles(inv, drop_pos):
	var curr_place = drop_pos
	for ore in inv:
		var amount = inv[ore]
		while amount > 0:
			var pile = 50 if amount > 50 else amount
			amount -= 50
			curr_place = Vector2(curr_place.x + DROPOFFSET, curr_place.y - DROPOFFSET)
			call_deferred("create_ore_pile", ore, pile, curr_place)

func create_ore_pile(ore_name, amount, location):
	var item = dropped_item.instantiate()
	item.SetVals(ore_name, amount)
	item.position = location
	get_parent().call_deferred("add_child", item)
	item.pickup_attempt.connect(ore_pile_entered)

@export var DROPOFFSET = 10
var ore_drop_offset = Vector2(0, 0)
func ShowRingOfDebug():
	var fake_inventory = Inventory.new(100).clear_inventory()
	var start_pos = position
	
	var the_x = start_pos.x / 64 if start_pos.x > 0 else (start_pos.x / 64) - 1
	var the_y = (start_pos.y / 64) + 1 if start_pos.y > 0 else (start_pos.y / 64)
	
	the_x = float(int(the_x) * 64)
	the_y = float(int(the_y) * 64)
	the_x += 64
	
	var m2l = Vector2(the_x, the_y)
	
	DropInventoryIntoPiles(fake_inventory, m2l)
	

func ore_pile_entered(drop_item, ore_type, number):
	var inv = Globals.TANK_INVENTORY
	var cant_fit = inv.add_to_inventory(ore_type, number)
	
	var msg = "Grabbed " + str(number - cant_fit) + " " + str(ore_type) + "s"
	$MovingNotifier.EnqueueMessage(msg)
	
	if cant_fit > 0:
		$MovingNotifier.EnqueueMessage("Inventory FULL")
		drop_item.amount = cant_fit
		drop_item.set_timeout()
	else:
		drop_item.queue_free()

func _on_gas_station_fill_gastank():
	fuel = FuelTankSize
	var fuel_percent = float(fuel) / FuelTankSize
	fuel_modified.emit(fuel_percent)
	$MovingNotifier.EnqueueMessage("Fueeled up!")
