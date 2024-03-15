extends Area2D

signal fill_gastank

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
var check_for_input = false
func _process(delta):
	if check_for_input:
		if Input.is_action_pressed("UseBuilding"):
			Globals.ACTION_TIMER.ExecOnElapsed("BuildingInteract", FillTank)
		else:
			Globals.ACTION_TIMER.Reset("BuildingInteract")

func FillTank():
	fill_gastank.emit()

func _on_body_entered(body):
	$Instruction.show()
	check_for_input = true

func _on_body_exited(body):
	$Instruction.hide()
	check_for_input = false
	Globals.ACTION_TIMER.Reset("BuildingInteract")
