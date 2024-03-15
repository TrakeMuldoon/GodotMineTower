class_name Inventory_Panel extends PopupPanel

# Called when the node enters the scene tree for the first time.
func _ready():
	var Grid = GridContainer.new()
	Grid.columns = 2
	add_child(Grid)
	
	var inv_ores = Globals.TANK_INVENTORY.ores_held
	for ore in inv_ores:
		var orename = Label.new()
		orename.text = ore
		var orenum = Label.new()
		orenum.text = str(inv_ores[ore])
		Grid.add_child(orename)
		Grid.add_child(orenum)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_popup_hide():
	pass # Replace with function body.
