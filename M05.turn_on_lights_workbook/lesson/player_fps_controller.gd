class_name PlayerFPSController extends CharacterBody3D

@export_range(0.001, 1.0) var mouse_sensitivity := 0.005
@export_range(0.001, 5.0) var joystick_sensitivity := 2.0

@export_category("Ground Movement")
@export_range(1.0, 10.0, 0.1) var max_speed_jog := 4.0
@export_range(1.0, 15.0, 0.1) var max_speed_sprint := 7.0
@export_range(1.0, 10.0, 0.1) var max_speed_crouch := 2.0
@export_range(1.0, 100.0, 0.1) var acceleration_jog := 15.0
@export_range(1.0, 100.0, 0.1) var acceleration_sprint := 25.0
@export_range(1.0, 100.0, 0.1) var deceleration := 12.0

@export_category("Air Movement")
@export_range(1.0, 50.0, 0.1) var gravity := 17.0
@export_range(1.0, 50.0, 0.1) var max_fall_speed := 20.0
@export_range(1.0, 20.0, 0.1) var jump_velocity := 8.0

var is_crouching := false: set = set_is_crounching

@onready var _camera: Camera3D = %Camera3D
@onready var _neck: Node3D = %Neck 
@onready var _neck_start_height: float = _neck.position.y
@onready var _collision_shape_3d: CollisionShape3D = %CollisionShape3D
@onready var _crounch_ceiling_cast: ShapeCast3D = %CrounchCeilingCast

@onready var _collision_shape_start_height: float = _collision_shape_3d.shape.height # = height of the initial player collision
@onready var _animation_player: AnimationPlayer = %FPSArmsModel.get_node("AnimationPlayer")

func _ready() -> void:
	_animation_player.playback_default_blend_time = 0.2

func _process(delta: float) -> void:
	var joystick_look_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var look_offset_2d = joystick_look_vector * joystick_sensitivity * delta
	_rotate_camera_by(look_offset_2d)

func _physics_process(delta: float) -> void:
	var input_direction_2d := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var movement_direction_2d := input_direction_2d.rotated(-1.0 * _camera.rotation.y)
	var movement_direction_3d := Vector3(movement_direction_2d.x, 0.0, movement_direction_2d.y)
	
	var player_wants_to_move := movement_direction_2d.length() > 0.1
	
	var velocity_ground_plane: Vector3 = Vector3(velocity.x, 0.0, velocity.z) # will contain input and stat_movement data
	var velocity_change: float = 0.0
	
	if player_wants_to_move:
		var max_speed := max_speed_jog
		var acceleration := acceleration_jog
		if Input.is_action_pressed("sprint"):
			max_speed = max_speed_sprint
			acceleration = acceleration_sprint
		if is_crouching: # when moving and crouch button pressed
			max_speed = max_speed_crouch
		
		velocity_change = acceleration * delta # update velocity data
		velocity_ground_plane = velocity_ground_plane.move_toward(movement_direction_3d * max_speed, velocity_change)
	else: # decelerating to stop
		velocity_change = deceleration * delta
		velocity_ground_plane = velocity_ground_plane.move_toward(Vector3.ZERO, velocity_change)
	
	# pass in the state of when crouch button is pressed or not, to is_crouching setter
	if is_on_floor():
		set_is_crounching(Input.is_action_pressed("crouching"))
	
	velocity.x = velocity_ground_plane.x
	velocity.z = velocity_ground_plane.z
	
	# add gravity to player
	if not is_on_floor():
		velocity.y -= gravity * delta
		velocity.y = maxf(velocity.y, -max_fall_speed)
	
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y  = jump_velocity
	
	#region Animation
	if is_on_floor() and player_wants_to_move:
		_animation_player.play("Walk")
		_animation_player.speed_scale = 0.5 + velocity.length() / max_speed_sprint
	else:
		_animation_player.play("Idle")
		_animation_player.speed_scale = 1.0
	#endregion 
	
	var was_in_air := not is_on_floor()
	var fall_speed := absf(velocity.y)
	
	move_and_slide() # remember to call this, if you want the body to update based on velocity
	var just_landed := was_in_air and is_on_floor()
	
	if just_landed:
		var impact_intensity := fall_speed / max_fall_speed # max 1.0, right? 

		var impact_tween := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		# line below: will decrease the camera y position of neck by 0.1
		impact_tween.tween_property(_neck, "position:y", _neck.position.y - 0.2 * impact_intensity, 0.06)
		impact_tween.tween_property(_neck, "position:y", _neck_start_height, 0.1) # back to orginal

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

func set_is_crounching(new_value: bool) -> void:
	if is_crouching == new_value:
		return # prevent any changes if crouching state is unchanged

	# on when player is no longer pressing crouch button,
	# check if player node has room to stop crouching above, otherwise return
	if new_value == false: # stopped pressing crouch button
		_crounch_ceiling_cast.force_shapecast_update()
		if _crounch_ceiling_cast.is_colliding():
			return
	
	is_crouching = new_value
	
	# when crouching, half the collision shape height, otherwise reset it back to default value
	if is_crouching:
		_collision_shape_3d.shape.height = _collision_shape_start_height / 2
	else:
		_collision_shape_3d.shape.height = _collision_shape_start_height
		
	# the vertcal or y value must be half of whatever the collision shape height is
	_collision_shape_3d.position.y = _collision_shape_3d.shape.height / 2
	
	# create a variable to store target height
	var neck_target_height := 0.0
	if is_crouching: # update viduals
		neck_target_height = _neck_start_height * 0.7 # target neck height will be at 70% the start
	else:
		neck_target_height = _neck_start_height # otherwise reset to start
	
	# tween to target neck height in 0.25 sec, trans_back and ease_out
	var crouch_tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	crouch_tween.tween_property(_neck, "position:y", neck_target_height, 0.25)

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
