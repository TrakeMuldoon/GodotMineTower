extends Area2D

signal entered_warehouse

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
var check_for_input = false
func _process(delta):
	if check_for_input:
		if Input.is_action_pressed("UseBuilding"):
			Globals.ACTION_TIMER.ExecOnElapsed("BuildingInteract", MoveInventory)
		else:
			Globals.ACTION_TIMER.Reset("BuildingInteract")

var queue = []
func MoveInventory():
	queue = []
	for ore in Globals.TANK_INVENTORY.get_ores():
		var local_inv = Globals.TANK_INVENTORY.remove_from_inventory(ore)
		Globals.GLOBAL_INVENTORY.add_to_inventory(ore, local_inv)
		var mt = MovingText.new()
		mt.position.y -= 40
		add_child(mt)
		var text = "Moved {num} {ore}".format({"num": local_inv, "ore": ore})
		mt.text = text
		queue.append(mt)
	write_messages()

func write_messages():
	if queue.size() == 0:
		return
	var next = queue.pop_front()
	next.go_to_it(0.4, 60)
	await get_tree().create_timer(0.15).timeout
	write_messages()

func _on_body_entered(body):
	check_for_input = true
	entered_warehouse.emit()

func _on_body_exited(body):
	check_for_input = false
	Globals.ACTION_TIMER.Reset("BuildingInteract")
	
