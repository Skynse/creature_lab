extends Camera3D

@export var pan_speed = 0.005
@export var move_speed = 10.0

var is_panning = false
var last_mouse_position = Vector2.ZERO
var spectating = false

func _ready():
	pass

func _process(delta):
	if Input.is_action_just_pressed("toggle_spectate"):
		spectating = !spectating
		Input.mouse_mode = spectating
		
	handle_keyboard_input(delta)

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				is_panning = true
				last_mouse_position = event.position
			else:
				is_panning = false
	
	elif event is InputEventMouseMotion and (spectating or is_panning):
		var mouse_delta = event.relative
		rotate_y(mouse_delta.x * -pan_speed)
		rotate_object_local(Vector3.RIGHT, mouse_delta.y * -pan_speed)
		

func handle_keyboard_input(delta):
	var input_dir = Vector3.ZERO
	input_dir.x = Input.get_axis("camera_left", "camera_right")
	input_dir.z = Input.get_axis("camera_up", "camera_back")
	
	if input_dir != Vector3.ZERO:
		translate(input_dir.normalized() * move_speed * delta)

	if Input.is_action_pressed("ui_accept"):
		translate(Vector3.UP * move_speed * delta)
