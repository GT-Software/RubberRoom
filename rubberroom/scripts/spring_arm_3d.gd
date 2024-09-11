extends SpringArm3D

@export var mouse_sensitivity = 0.05

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set to move independently from the Player
	set_as_top_level(true)
	# Captures the mouse movement for camera transformation
	# Pesky mouse go bye bye
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# Pitch camera up and down
		rotation_degrees.x -= event.relative.y * mouse_sensitivity
		# Clamp prevents camera from rolling upside down, etc.
		rotation_degrees.x = clamp(rotation_degrees.x, -90.0, 30.0)
		
		rotation_degrees.y -= event.relative.x * mouse_sensitivity
		# Rotation won't accumulate
		rotation_degrees.y = wrapf(rotation_degrees.y, 0.0, 360.0)
