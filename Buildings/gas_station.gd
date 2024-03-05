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
	#var mt = MovingText.new()
	#mt.position.y -= 40
	#add_child(mt)
	#var text = "Fueled Up!"
	#mt.text = text
	#mt.go_to_it(0.4, 60)

func _on_body_entered(body):
	check_for_input = true
	#entered_warehouse.emit()

func _on_body_exited(body):
	check_for_input = false
	Globals.ACTION_TIMER.Reset("BuildingInteract")
