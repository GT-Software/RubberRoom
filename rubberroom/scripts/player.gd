extends CharacterBody3D

# TODO: Set up camera rotation for controller

@export var SPEED = 5.0
@export var RUN_SPEED = 8.5
@export var CROUCH_SPEED = 2.5
@export var JUMP_VELOCITY = 20.0
# In case we want gravity
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var _velocity = Vector3.ZERO

var is_crouched = false

# Spring Arm to hold the camera
@onready var _spring_arm : SpringArm3D = $SpringArm3D
# This is our model variable, currently a placeholder.
@onready var _model : MeshInstance3D = $MeshInstance3D

# Sets our direcitonal vector to [0, 0, 0] so we can clearly move around effectively.
var move_direction = Vector3.ZERO



# I am not putting anything into separate functions right now, I just want it to work. Be organized, but optimize later.
func _physics_process(delta: float) -> void:
	
	if not is_on_floor():
		velocity.y -= gravity * delta * 20
	
	# We use the is_on_floor() method and the snap vector to check if the player landed
	# These are boolean variables being set to true/false based on these condition
	var is_jumping = is_on_floor() and Input.is_action_just_pressed("jump")
	# If the player is jumping, set y-velocity to the jump velocity, and the snap vector to a zero vector
	if is_jumping:
		velocity.y = JUMP_VELOCITY
	
	# We are using get_action_strength here, because I added controller input mapping, will help us later.
	move_direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	move_direction.z = Input.get_action_strength("backward") - Input.get_action_strength("forward")
	# Normalizing to prevent diagonal speed boost
	move_direction = move_direction.rotated(Vector3.UP, _spring_arm.rotation.y).normalized()
	
	# Setting _velocity to new values depending on the player's stance
	if Input.is_action_pressed("run") and not is_crouched:
		velocity.x = move_direction.x * RUN_SPEED
		velocity.z = move_direction.z * SPEED
		print("The Player is Running")
	elif Input.is_action_pressed("crouch"):
		velocity.x = move_direction.y * CROUCH_SPEED
		velocity.z = move_direction.z * CROUCH_SPEED
		print("The Player is Crouching")
		is_crouched = !is_crouched
	else:
		velocity.x = move_direction.x * SPEED
		velocity.z = move_direction.z * SPEED
		print("The Player is Walking")
		
	move_and_slide()
	
	# Allows the player to turn around realistically (Placeholder does not show that, must test)
	if _velocity.length() > 0.2:
		var look_direction = Vector2(_velocity.z, _velocity.x)
		_model.rotation.y = look_direction.angle()
	
func _process(delta: float) -> void:
	# Update the spring arm to move with the character every frame
	_spring_arm.position = position
	
