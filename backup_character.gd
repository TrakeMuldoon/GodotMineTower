extends CharacterBody2D

@export var Speed : float = 300.0
@export var Jump_Velocity : float = -400.0
signal character_moved
signal drilled
signal build_wall

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var tilemap 

func _ready():
	tilemap = get_tree().get_current_scene().get_node("WorldLevel").get_node("GroundMap")

var drill_down_counter = 0
var drill_side_counter = 0
func _physics_process(delta):
	if Input.is_action_just_pressed("Wall") and is_on_floor():
		Build_Wall_Maybe()
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("go_up"): # and is_on_floor():
		velocity.y = Jump_Velocity

	if Input.is_action_pressed("go_down") and is_on_floor():
		if drill_down_counter > 25:
			Drill_Down()
			drill_down_counter = 0
		else:
			drill_down_counter += 1
	else:
		drill_down_counter = 0
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("go_left", "go_right")
	
	if direction:
		if is_on_wall() and is_on_floor():
			if drill_side_counter > 25:
				Drill_Side(direction)
				drill_side_counter = 0
			else:
				drill_side_counter += 1
		else:
			drill_side_counter = 0
		velocity.x = direction * Speed
		if velocity.x < 0:
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false
	else:
		velocity.x = move_toward(velocity.x, 0, Speed)

	move_and_slide()

	character_moved.emit(position)

func Build_Wall_Maybe():
	if $Headroom.has_overlapping_bodies():
		return
	velocity.y = Jump_Velocity * 0.1
	var pos = Vector2(position.x, position.y)
	var l2m = tilemap.local_to_map(pos)
	if l2m.y < 0:
		l2m.y -= 4
	if l2m.x < 0:
		l2m.x -= 4
	l2m.y = l2m.y / 4
	l2m.x = l2m.x / 4
	position.y -= 64
	build_wall.emit(l2m)

func Drill_Down():
	velocity.y = Jump_Velocity * 0.1
	var pos = Vector2(position.x, position.y + 32)
	var l2m = tilemap.local_to_map(pos)
	#if l2m.y < 0:
	#	l2m.y -= 4
	if l2m.x < 0:
		l2m.x -= 4
	l2m.y = l2m.y / 4
	l2m.x = l2m.x / 4
	drilled.emit(l2m)

func Drill_Side(direction):
	velocity.y = Jump_Velocity * 0.1
	var pos = Vector2(position.x + (direction * 64), position.y)
	var l2m = tilemap.local_to_map(pos)
	if l2m.y < 0:
		l2m.y -= 4
	if l2m.x < 0:
		l2m.x -= 4
	l2m.y = l2m.y / 4
	l2m.x = l2m.x / 4
	drilled.emit(l2m)
	
