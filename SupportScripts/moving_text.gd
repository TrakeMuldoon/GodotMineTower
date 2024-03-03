class_name MovingText extends Label

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()

var started = false
var elapsed_time = 0
var target_time = 0
var distance = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(started):
		position.y -= (float(delta) / target_time) * distance
		elapsed_time += delta
		if elapsed_time > target_time:
			queue_free()

func go_to_it(time, x_delta):
	show()
	target_time = time * 1
	distance = x_delta
	started = true
