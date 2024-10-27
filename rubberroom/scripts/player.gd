extends CharacterBody3D


#signals
signal stamina_change(new_stamina)
signal health_change
signal stun_change
signal fear_change

# TODO: Set up camera rotation for controller

@onready var player_stat_bars = $"Player Stat Bars"
@onready var health_bar = $"Player Stat Bars/HealthBar"
@onready var stun_bar = $"Player Stat Bars/StunBar"
@onready var stamina_bar = $"Player Stat Bars/StaminaBar"
@onready var fear_bar = $"Player Stat Bars/FearBar"


#Component Data
var health_component : HealthComponent = HealthComponent.new()
var stun_component : StunComponent = StunComponent.new()
var stamina_component : StaminaComponent = StaminaComponent.new()
var fear_component : FearComponent = FearComponent.new()


@export var SPEED = 5.0
@export var RUN_SPEED = 8.5
@export var CROUCH_SPEED = 2.5
@export var JUMP_VELOCITY = 5.0

var current_speed = 0.0

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


func _ready():
	
	
	health_bar.init_health(health_component)
	stun_bar.init_stun(stun_component)
	stamina_bar.init_stamina(stamina_component)
	fear_bar.init_fear(fear_component)
	#Should set Health to MAX


# I am not putting anything into separate functions right now, I just want it to work. Be organized, but optimize later.
func _physics_process(delta):
	
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# We use the is_on_floor() method and the snap vector to check if the player landed
	# These are boolean variables being set to true/false based on these condition
	var is_jumping = is_on_floor() and Input.is_action_just_pressed("jump")
	# If the player is jumping, set y-velocity to the jump velocity, and the snap vector to a zero vector
	if is_jumping:
		velocity.y = JUMP_VELOCITY
	
	## We are using get_action_strength here, because I added controller input mapping, will help us later.
	#move_direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	#move_direction.z = Input.get_action_strength("backward") - Input.get_action_strength("forward")
	## Normalizing to prevent diagonal speed boost
	#move_direction = move_direction.rotated(Vector3.UP, _spring_arm.rotation.y).normalized()
	
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	move_direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	move_direction = move_direction.rotated(Vector3.UP, _spring_arm.rotation.y)
	
	# Setting _velocity to new values depending on the player's stance
	if Input.is_action_pressed("run") and not is_crouched:
		current_speed = RUN_SPEED
		velocity.x = move_direction.x * RUN_SPEED
		velocity.z = move_direction.z * RUN_SPEED
		stamina_component.stamina_drain()
		emit_signal("stamina_change", stamina_component.stamina)
		#print(stamina_component.stamina)
		print("The Player is Running")
	if Input.is_action_pressed("crouch"):
		current_speed = CROUCH_SPEED
		velocity.x = move_direction.x * CROUCH_SPEED
		velocity.z = move_direction.z * CROUCH_SPEED
		print("The Player is Crouching")
		is_crouched = !is_crouched
	if !Input.is_action_pressed("run") and !Input.is_action_pressed("crouch"):
		current_speed = SPEED
		velocity.x = move_direction.x * SPEED
		velocity.z = move_direction.z * SPEED
		print("The Player is Walking")
		
	move_and_slide()
	print(current_speed)
	# Allows the player to turn around realistically (Placeholder does not show that, must test)
	if _velocity.length() > 0.2:
		var look_direction = Vector2(_velocity.z, _velocity.x)
		_model.rotation.y = look_direction.angle()
	
func _process(delta: float) -> void:
	# Update the spring arm to move with the character every frame
	_spring_arm.position = position
	
	
