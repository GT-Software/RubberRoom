extends CharacterBody3D


const SPEED = 3.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var camera_point = $Camera_Point
@onready var _spring_arm : SpringArm3D = $SpringArm3D
#Animation Variables
@onready var visuals = $Visuals
@onready var animation_player = $Visuals/player/AnimationPlayer
var walking = false

func _process(delta: float) -> void:
	# Update the spring arm to move with the character every frame
	_spring_arm.position = position

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
		#visuals.look_at(direction + position)
		
		#Walking On
		if !walking:
			walking = true
			#animation_player.play("walk")
		
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
		#Walking Off
		if walking:
			walking = false
		#	animation_player.play("idle")

	move_and_slide()
