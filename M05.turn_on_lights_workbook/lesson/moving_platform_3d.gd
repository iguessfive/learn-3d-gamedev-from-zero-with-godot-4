@tool
class_name MovingPlatform3D extends Node3D

@export var end_marker: Marker3D = null
@export var is_active: bool = false: set = set_is_active

@export_group("Animation")
@export var pause_duration := 1.5
@export var move_duration := 2.0

@onready var _start_position := global_position
@onready var _platform: AnimatableBody3D = %AnimatableBody3D

var _tween: Tween = null

func _ready() -> void:
	set_is_active(is_active)
	
	if not Engine.is_editor_hint() and is_active:
		_moving_platform_animation()

func set_is_active(new_value: bool) -> void:
	is_active = new_value
	
	if _tween != null:
		_tween.kill()
	
	if not is_inside_tree() and end_marker == null:
		return
	
	if not is_active:
		return
		
	if Engine.is_editor_hint():
		_moving_platform_animation()
	
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := []
	if end_marker == null:
		warnings.append(
			"The platform needs an end marker to know where to move to. " +
			"It should be a node that extends Marker3D. Assign in the Inspector."
		)
	return warnings

func _moving_platform_animation() -> void:
		_tween = create_tween()
		_tween.set_loops()
		_tween.tween_property(
			_platform, "global_position", end_marker.global_position, move_duration
		).set_delay(pause_duration)
		_tween.tween_property(
			_platform, "global_position", _start_position, move_duration
		).set_delay(pause_duration)
