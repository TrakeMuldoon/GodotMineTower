extends Area2D

signal entered_warehouse
signal moved_inventory

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

func MoveInventory():
	for ore in Globals.TANK_INVENTORY.get_ores():
		var local_inv = Globals.TANK_INVENTORY.remove_from_inventory(ore)
		var leftover = Globals.GLOBAL_INVENTORY.add_to_inventory(ore, local_inv)
		if leftover > 0:
			assert("Earthshattering bad thing")
		var text = "Moved {num} {ore}".format({"num": local_inv, "ore": ore})
		moved_inventory.emit(text)
		$MovingNotifier.EnqueueMessage(text)

func _on_body_entered(body):
	check_for_input = true
	$Instruction.show()
	entered_warehouse.emit()

func _on_body_exited(body):
	check_for_input = false
	$Instruction.hide()
	Globals.ACTION_TIMER.Reset("BuildingInteract")
