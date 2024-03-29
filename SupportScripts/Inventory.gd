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
	##add_to_inventory("SILVER", 5)

func add_to_inventory(label, count):
	var can_fit = count if count + held_count <= max else max - held_count
	held_count += can_fit
	if not label in ores_held:
		ores_held[label] = 0
	ores_held[label] += can_fit
	inventory_modified.emit()
	return count - can_fit

func unsafe_add_to_inventory_delayed(label, count):
	if not label in ores_held:
		ores_held[label] = 0.0
	ores_held[label] += count

func fire_modified():
	inventory_modified.emit()

func remove_from_inventory(label):
	var value = ores_held[label]
	ores_held.erase(label)
	held_count -= value
	inventory_modified.emit()
	return value
	
func get_ores():
	var ore_list = []
	for ore in ores_held:
		ore_list.append(ore)
	return ore_list
	
func get_value(ore):
	return ores_held[ore]

func clear_inventory():
	var previous_inventory = ores_held
	ores_held = {}
	held_count = 0
	inventory_modified.emit()
	return previous_inventory

func HUD_printout():
	var output = "floop\n"
	for label in ores_held:
		output += "{lab} :> {val}\n".format({"lab":label, "val":ores_held[label]})
	return output
