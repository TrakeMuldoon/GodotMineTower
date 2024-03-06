class_name MovingNotifier extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

var messages = []
var writing = false

func EnqueueMessage(message):
	messages.append(message)
	if not writing:
		writing = true
		WriteMessages()

func WriteMessages():
	while(messages.size() > 0):
		var next = messages.pop_front()
		var mt = MovingText.new()
		add_child(mt)
		mt.text = next
		mt.go_to_it(0.5, 80)
		await get_tree().create_timer(0.14).timeout
	writing = false
