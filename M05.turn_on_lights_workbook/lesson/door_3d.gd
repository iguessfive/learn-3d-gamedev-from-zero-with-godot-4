class_name Door3D extends Interactable3D

# a bool to hold value when door is open or closed, use a setter to update collider diabled propety
var is_active := false: set = set_is_active

var _tween_door: Tween = null

# access to door collider node
@onready var _static_body_collision_shape_3d: CollisionShape3D = %StaticBodyCollisionShape3D
@onready var _door_bottom: MeshInstance3D = $Door/DoorBottom
@onready var _door_top: MeshInstance3D = $Door/DoorTop

# update interact function from parent
func interact() -> void:
	super()
	set_is_active(not is_active)

# a setter for bool to update value
func set_is_active(new_value: bool) -> void:
	is_active = new_value
	_static_body_collision_shape_3d.disabled = is_active
	
	# animation for opening and closing door
	# store values for top and bottom value open and closed use ternary expression to choose between values
	var top_value: float = 2.0 if is_active else 1.0
	var bottom_value: float = -0.0 if is_active else 1.0
	
	# check if tween is not null and stop and remove tween
	if _tween_door != null:
		_tween_door.kill()
	# create the tween and set it to parallel to animate the opening of both parts of door at once
	_tween_door = create_tween().set_parallel(true)
	
	# assign tween movement type, ease_out and trans_back if active otherwise trans_bounce
	_tween_door.set_ease(Tween.EASE_OUT)
	_tween_door.set_trans(Tween.TRANS_BACK if is_active else Tween.TRANS_BOUNCE)
	
	# animate the tween position property of the mesh instances
	_tween_door.tween_property(_door_top, "position:y", top_value, 1.0)
	_tween_door.tween_property(_door_bottom, "position:y", bottom_value, 1.0)
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		interact()
