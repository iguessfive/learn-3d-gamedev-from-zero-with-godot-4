## 3D object that can be highlighted when the player aims at it and that the
## player can interact with.
##
## We do not use Area3D.mouse_entered and mouse_exited because:
##
## - We want to highlight the object when the player is looking at it, even if
## they play with the gamepad or release the mouse cursor from the game window.
## - We don't want to highlight the object when the player interacts with it or
## picks it up.
@tool
class_name Interactable3D extends Area3D

## Emitted when the player interacts with the node.
signal interacted_with

const MATERIAL_HIGHLIGHT = preload("res://assets/highlight_overlay.tres")

@export var mesh_instances: Array[MeshInstance3D] = []: set = set_mesh_instances
@export var is_highlighted := false: set = set_is_highlighted

var _tween: Tween = null


func _init() -> void:
	monitoring = false


func _ready() -> void:
	set_is_highlighted(is_highlighted)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	if mesh_instances.is_empty():
		warnings.append("The mesh_instances array is empty. You need to assign at least one MeshInstance3D to this node for highlighting to work.")
	return warnings


func set_mesh_instances(new_mesh_instances: Array[MeshInstance3D]) -> void:
	mesh_instances = new_mesh_instances
	for mesh_instance in mesh_instances:
		if mesh_instance != null:
			if is_highlighted:
				mesh_instance.material_overlay = MATERIAL_HIGHLIGHT
			else:
				mesh_instance.material_overlay = null


func set_is_highlighted(new_value: bool) -> void:
	if is_highlighted == new_value:
		return

	is_highlighted = new_value
	if not mesh_instances.is_empty():
		if _tween != null:
			_tween.kill()
		_tween = create_tween()

		if is_highlighted:
			for mesh_instance in mesh_instances:
				mesh_instance.material_overlay = MATERIAL_HIGHLIGHT
			_tween.tween_method(set_material_alpha, 0.0, 1.0, 0.1)
		else:
			_tween.tween_method(set_material_alpha, 1.0, 0.0, 0.1)
			_tween.tween_callback(func():
				for mesh_instance in mesh_instances:
					mesh_instance.material_overlay = null
			)


func set_material_alpha(alpha: float) -> void:
	MATERIAL_HIGHLIGHT.set_shader_parameter("alpha", alpha)


## Virtual function. Called when interacting with the node.
## Override the function to make the interactable do something.
func interact() -> void:
	interacted_with.emit()
