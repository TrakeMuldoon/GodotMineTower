extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	$CameraLocation.text = str(Globals.RANDOM_SEED)


# Called every frame. 'delta' is the elapsed time since the previous frame.
var counter = 0
func _process(delta):
	$DrillDown.value = Globals.ACTION_TIMER.GetProgress("DrillDown") * 100
	$DrillSide.value = Globals.ACTION_TIMER.GetProgress("DrillSide") * 100
	$ResetBar.value = Globals.ACTION_TIMER.GetProgress("Reset") * 100

func _on_backup_character_character_moved(pos):
	var scene = get_tree().get_current_scene()
	var tilemap = scene.get_node("WorldLevel").get_node("GroundMap")
	var posy = Vector2(pos.x, pos.y + 32)
	var l2m = tilemap.local_to_map(posy)
	l2m.y = l2m.y / 4
	l2m.x = l2m.x / 4
	
	var modPosition = Vector2((pos.x - 32)/4, (pos.y + 32) / 4)
	$PlayerLocation.text = "Player Location:\n" + str(pos) + "\n" + str(modPosition) + "\n" + str(l2m)  
	pass # Replace with function body.
