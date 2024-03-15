class_name MineManager extends Node

var resource_value_per_second = {}
var timer_time = 99

func _init(times_per_sec):
	timer_time = 1.0 / times_per_sec
	var timer = Timer.new()
	timer.wait_time = timer_time
	timer.one_shot = false
	timer.connect("timeout", on_timer_timeout)
	timer.autostart = true
	Globals.add_child(timer)
	timer.start()
	
func on_timer_timeout():
	for ore in resource_value_per_second:
		var val = resource_value_per_second[ore] * timer_time
		Globals.GLOBAL_INVENTORY.unsafe_add_to_inventory_delayed(ore, val)
	Globals.GLOBAL_INVENTORY.fire_modified()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func Add_Mine(resource, value):
	if not resource in resource_value_per_second:
		resource_value_per_second[resource] = 0
	resource_value_per_second[resource] += value
