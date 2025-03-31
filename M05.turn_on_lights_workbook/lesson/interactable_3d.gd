class_name Interactable3D extends Area3D

# signal to emit what object is interacted with
signal interact_with

const MATERIAL_HIGHLIGHT = preload("res://assets/highlight_overlay.tres")

@export var mesh_instances: Array[MeshInstance3D] = []: set = set_mesh_instances
@export var is_highlighted: bool = false: set = set_is_highlighted

var _tween_highlight: Tween = null

# initialise object so that it can not monitor anything else, it can only be detected (inanimated object)
func _init() -> void:
	monitoring = false

# a function to emit signal when interacted
func interact() -> void:
	interact_with.emit()

func set_mesh_instances(new_mesh_instances: Array[MeshInstance3D]) -> void:
	# assign passed in argument to property using parameter name
	mesh_instances = new_mesh_instances
	
	if mesh_instances.is_empty():
		return
	
	# for each mesh instance check if it's not null
	for mesh_instance: MeshInstance3D in mesh_instances:
		# removing the material overlay is awesome, it means that one resource is used to showcase
		# interactable when player is looking at item and saves rendering performance
		if is_highlighted: # then if player is looking at door add shader else remove shader
			mesh_instance.material_overlay = MATERIAL_HIGHLIGHT
		else:
			mesh_instance.material_overlay = null

func set_is_highlighted(new_value: bool) -> void: 
	is_highlighted = new_value
	
	if mesh_instances.is_empty():
		return
	
	# Animation for shader alpha value fading in and out
	if _tween_highlight != null:
		_tween_highlight.kill()
	
	_tween_highlight = create_tween()
	_tween_highlight.set_ease(Tween.EASE_OUT)
	_tween_highlight.set_trans(Tween.TRANS_SINE)
	
	# tween from current shader alpha variable
	var current_alpha: float = MATERIAL_HIGHLIGHT.get_shader_parameter("alpha") # IMPORTANT when using shader
	
	if is_highlighted:
		for mesh_instance in mesh_instances:
			mesh_instance.material_overlay = MATERIAL_HIGHLIGHT
		_tween_highlight.tween_method(set_alpha_value, current_alpha, 1.0, 1.0)
	else:
		_tween_highlight.tween_method(set_alpha_value, current_alpha, 0.0, 1.0)
		_tween_highlight.tween_callback(func():
			for mesh_instance in mesh_instances:
				(mesh_instance as MeshInstance3D).material_overlay = null
		)

func set_alpha_value(new_value) -> void:
	# use material const resource as it's assigned to all meshe instances
	MATERIAL_HIGHLIGHT.set_shader_parameter("alpha", new_value)
	
