class_name OrePile extends Area2D

var From_Map_Generation = false

var amount = 50
var ore_type = "COAL"

func _init(type = "COAL", value = 15):
	SetVals(type, value)

# This is because the Instantiate cannot have params... or can it?
func SetVals(type, value):
	ore_type = type
	amount = value
	
# Called when the node enters the scene tree for the first time.
func _ready():
	$PileShape.animation = ore_type
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_area_entered(area):
	pass # Replace with function body.
