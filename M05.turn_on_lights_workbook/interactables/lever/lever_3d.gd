@tool
class_name Lever3D extends Interactable3D

signal switched(is_active: bool)

@export var is_active: bool = false: set = set_is_active

@export_group("Appearance")
@export var color_active := Color("ffcb2e")
@export var color_inactive := Color("cfddff")

var _tween_lever: Tween = null

@onready var _lever_handle: MeshInstance3D = $Lever3D/LeverHandle
@onready var _handle_tip_material: StandardMaterial3D = _lever_handle.get_surface_override_material(1)

func _ready() -> void:
	interact_with.connect(func():
		set_is_active(not is_active)
	)
	set_is_active(is_active)
	
func set_is_active(new_value: bool) -> void:
	if is_active != new_value:
		switched.emit(new_value)
	
	is_active = new_value
	
	if not is_inside_tree():
		return
	
	if _tween_lever != null:
		_tween_lever.kill()
	
	_tween_lever = create_tween()
	_tween_lever.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN_OUT)
	var target_angle := -1.0 * PI / 3 if is_active else PI / 3.0
	_tween_lever.tween_property(_lever_handle, "rotation:z", target_angle, 0.5)
	
	var color: Color = color_active if is_active else color_inactive
	_tween_lever.parallel().tween_property(_handle_tip_material, "albedo_color", color, 0.2)

	
