class_name DroppedItem extends RigidBody2D
var From_Map_Generation = false

var amount = 50
var ore_type = "COAL"

signal pickup_attempt

func _init(type = "COAL", value = 1):
	ore_type = type
	amount = value

# This is because the Instantiate cannot have params
func SetVals(type, value):
	ore_type = type
	amount = value
	
# Called when the node enters the scene tree for the first time.
var summoning_sickness = true
func _ready():
	var timer := Timer.new()
	add_child(timer)
	timer.wait_time = 0.1
	timer.one_shot = true
	timer.connect("timeout", _on_timer_timeout)
	timer.start()
	$PileShape.animation = ore_type
	pass
	
func _on_timer_timeout() -> void:
	summoning_sickness = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_collection_area_area_entered(area):
	pass


func _on_collection_area_body_entered(body):
	if summoning_sickness:
		return
	var areas = $CollectionArea.get_overlapping_areas()
	var nodes = $CollectionArea.get_overlapping_bodies()
	if nodes.size() > 0:
		pickup_attempt.emit(ore_type, amount)
