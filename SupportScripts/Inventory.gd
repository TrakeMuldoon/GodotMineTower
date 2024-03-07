class_name Inventory extends Node

var max
var held_count = 0
var ores_held = {}
signal inventory_modified

func _init(_max):
	max = _max
	debug_stuff()

func debug_stuff():
	add_to_inventory("COAL", 5)
	add_to_inventory("IRON", 5)
	add_to_inventory("COPPER", 5)
	add_to_inventory("MAGNESIUM", 5)
	add_to_inventory("SILVER", 5)

func add_to_inventory(label, count):
	if count + held_count > max:
		return false
		
	held_count += count
	if not label in ores_held:
		ores_held[label] = 0
	ores_held[label] += count
	inventory_modified.emit()
	return true

func remove_from_inventory(label):
	var value = ores_held[label]
	ores_held.erase(label)
	inventory_modified.emit()
	return value
	
func get_ores():
	var ore_list = []
	for ore in ores_held:
		ore_list.append(ore)
	return ore_list

func clear_inventory():
	var previous_inventory = ores_held
	ores_held = {}
	inventory_modified.emit()
	return previous_inventory

func HUD_printout():
	var output = "floop\n"
	for label in ores_held:
		output += "{lab} :> {val}\n".format({"lab":label, "val":ores_held[label]})
	return output
