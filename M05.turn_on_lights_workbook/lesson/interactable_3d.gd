class_name Interactable3D extends Area3D

# signal to emit what object is interacted with
signal interact_with

# initialise object so that it can not monitor anything else, it can only be detected (inanimated object)
func _init() -> void:
	monitoring = false

# a function to emit signal when interacted
func interact() -> void:
	interact_with.emit()
