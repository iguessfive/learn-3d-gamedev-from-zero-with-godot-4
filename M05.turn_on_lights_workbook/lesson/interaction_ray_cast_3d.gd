class_name InterationRaycast3D extends RayCast3D

# create a variable to store interactable object at collsion 
var _focused_node: Interactable3D = null

# when object is created disable collisions for physics bodies and only detect areas
func _init() -> void:
	enabled = false # will not detect for collisions at the end of physics frame
	
	collide_with_bodies = false
	collide_with_areas = true 

# handle input for interaction in gameplay
func _unhandled_input(event: InputEvent) -> void:
	if _focused_node != null and event.is_action_pressed("interact"):
		_focused_node.interact()

# each frame for collsions check if the raycast is colliding with area
# and assign that to class variable
@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	force_raycast_update() # check for collision at the start of the physics frame call - by default one frame behind 
	var collider = get_collider() as Interactable3D

	#before new focused node is set, update player highlight
	if collider == null and _focused_node != null:
		_focused_node.is_highlighted = false
		
	_focused_node = collider # new focused node this frame
	
	# if the collider by raycast is a `Interactable3D` then...
	if _focused_node != null: # animation is never playing fully, repeatedly being called, 
		# not enough time for tween to play through
		_focused_node.is_highlighted = true
			
		
		
		
	
