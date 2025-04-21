@tool
class_name MovingPlatform3D extends Node3D

@export var end_marker: Marker3D = null
@export var linked_lever: Lever3D = null: set = set_linked_lever
@export var is_active: bool = false: set = set_is_active

@export_group("Animation")
@export var pause_duration := 1.5
@export var move_duration := 2.0

@export_group("Appearance")
@export var color_active := Color("ffcb2e")
@export var color_inactive := Color("f6a6ff")

var _tween: Tween = null

@onready var _start_position := global_position
@onready var _platform: AnimatableBody3D = %AnimatableBody3D
@onready var _csg_box_3d: CSGBox3D = %CSGBox3D

func _ready() -> void:
	set_is_active(is_active)
	set_linked_lever(linked_lever)
	
func set_linked_lever(new_lever: Lever3D) -> void:
	if linked_lever != null and linked_lever.switched.is_connected(set_is_active):
		linked_lever.switched.disconnect(set_is_active)
	
	linked_lever = new_lever
	if not is_inside_tree():
		return
		
	if linked_lever != null:
		linked_lever.switched.connect(func(is_lever_active: bool):
			set_is_active(is_lever_active)
		)
		
func set_is_active(new_value: bool) -> void:
	is_active = new_value
	
	var tween_color = create_tween()
	var color: Color = color_active if is_active else color_inactive
	tween_color.tween_property(_csg_box_3d.material_override, "albedo_color", color, 0.2)
	

	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	
	if not is_inside_tree() and end_marker == null:
		return
		
	if not is_active:
		# false, so platform stops
		_tween.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		_tween.tween_property(_platform, "global_position", _start_position, move_duration)
		return
	
	_tween.set_loops()
	_tween.tween_property(
		_platform, "global_position", end_marker.global_position, move_duration
	).set_delay(pause_duration)
	_tween.tween_property(
		_platform, "global_position", _start_position, move_duration
	).set_delay(pause_duration)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := []
	if end_marker == null:
		warnings.append(
			"The platform needs an end marker to know where to move to. " +
			"It should be a node that extends Marker3D. Assign in the Inspector."
		)
	return warnings
