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
	pass

func MoveInventory():
	Globals.GLOBAL_INVENTORY.add_to_inventory("murh", 5)

func _on_body_entered(body):
	check_for_input = true
	entered_warehouse.emit()

func _on_body_exited(body):
	check_for_input = false
	Globals.ACTION_TIMER.Reset("BuildingInteract")
	
