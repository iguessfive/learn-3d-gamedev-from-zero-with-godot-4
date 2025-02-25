class_name PlayerFPSController extends CharacterBody3D

@export_range(0.001, 1.0) var mouse_sensitivity := 0.005
@export_range(0.001, 5.0) var joystick_sensitivity := 2.0

@onready var _camera: Camera3D = %Camera3D

func _process(delta: float) -> void:
	var joystick_look_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var look_offset_2d = joystick_look_vector * joystick_sensitivity * delta
	_rotate_camera_by(look_offset_2d)


func _unhandled_input(event: InputEvent) -> void:
	var is_mouse_button := event is InputEventMouseButton
	var is_mouse_captured := Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
	var is_escape_pressed := event.is_action_pressed("ui_cancel")
	
	if is_mouse_button and not is_mouse_captured:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif is_escape_pressed and is_mouse_captured:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
	if (event is InputEventMouseMotion and is_mouse_captured):
		var look_offset_2d: Vector2 = event.screen_relative * mouse_sensitivity
		_rotate_camera_by(look_offset_2d)
	
func _rotate_camera_by(look_offset_2d: Vector2) -> void:
	#how to rotate left and right
	_camera.rotation.y -= look_offset_2d.x
	#how to rotate up and down
	_camera.rotation.x -= look_offset_2d.y
	# limit rotation values when turning left or right
	_camera.rotation.y = wrapf(_camera.rotation.y, -PI, PI)
	
	const MAX_VERTICAL_ANGLE := PI/3.0
	_camera.rotation.x = clampf(_camera.rotation.x, -1.0 * MAX_VERTICAL_ANGLE, MAX_VERTICAL_ANGLE)
	_camera.orthonormalize()
