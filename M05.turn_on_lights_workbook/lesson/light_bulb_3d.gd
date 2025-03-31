class_name LightBulb3D extends Interactable3D

var is_active: bool = false: set = set_is_active

var _tween_bulb: Tween

@onready var _bulb: MeshInstance3D = $lightbulb/Bulb

func interact() -> void:
	super()
	is_active = not is_active

func set_is_active(new_value) -> void: 
	is_active = new_value
	
	var brightness_level: float = 1.0 if is_active else 0.0
	
	# animation for light bulb
	if _tween_bulb != null:
		_tween_bulb.kill()
	
	_tween_bulb = create_tween()
	_tween_bulb.set_ease(Tween.EASE_OUT)
	_tween_bulb.set_trans(Tween.TRANS_SINE)
	
	_tween_bulb.tween_property(_bulb.material_override, "emission_energy_multiplier", brightness_level, 1.0) 
	

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		set_is_active(not is_active)
