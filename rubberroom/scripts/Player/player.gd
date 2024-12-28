extends CharacterBody3D

# -------------------------------
# Signals
# -------------------------------
signal stamina_change(new_stamina)
signal health_change
signal stun_change
signal fear_change

# -------------------------------
# Node references
# -------------------------------
@onready var canvas_layer = $"../CanvasLayer"
@onready var ap = $AuxScene/AnimationPlayer

@onready var player_stat_bars = $"../CanvasLayer/Player Stat Bars"
@onready var health_bar     = $"../CanvasLayer/Player Stat Bars/HealthBar"
@onready var stun_bar       = $"../CanvasLayer/Player Stat Bars/StunBar"
@onready var stamina_bar    = $"../CanvasLayer/Player Stat Bars/StaminaBar"
@onready var fear_bar       = $"../CanvasLayer/Player Stat Bars/FearBar"
@onready var _player_pcam   = $"../Camera Controller/PhantomCamera3D"
@onready var camera_anchor: Node3D = $"RotationPoint/Camera Anchor"
@onready var rotation_point: Node3D = $RotationPoint

@export var mouse_sensitivity: float = 0.05
@export var min_pitch: float = -89.9
@export var max_pitch: float = 50
@export var min_yaw: float = 0
@export var max_yaw: float = 360

# -------------------------------
# Components
# -------------------------------
var health_component : HealthComponent = HealthComponent.new()
var stun_component   : StunComponent   = StunComponent.new()
var stamina_component: StaminaComponent= StaminaComponent.new()
var fear_component   : FearComponent   = FearComponent.new()

# Movement constants
const SPEED        = 5.0
const RUN_SPEED    = 15.0
const CROUCH_SPEED = 1.0
const JUMP_VELOCITY= 5.0

# -------------------------------
# Animation Vars
# -------------------------------
var is_idle     = false
var is_walking  = false
var is_running  = false
var locked_on   = false
var is_crouched = false

var current_speed = 0.0

# Gravity from ProjectSettings
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var _velocity = Vector3.ZERO

@onready var _spring_arm : SpringArm3D     = $SpringArm3D
@onready var _model      : MeshInstance3D  = $MeshInstance3D

var move_direction = Vector3.ZERO

var is_in_range = false
var enemy

func _ready():
	health_bar.init_health(health_component)
	stun_bar.init_stun(stun_component)
	stamina_bar.init_stamina(stamina_component)
	fear_bar.init_fear(fear_component)
	rotation_point.set_as_top_level(true)


func _physics_process(delta):
	rotation_point.position = position
	
	
	#---------------------------------
	# 1) Gravity + Death check
	#---------------------------------
	if health_component.get_health() <= 0:
		queue_free()
	
	if not is_on_floor():
		velocity.y -= gravity * delta

	#---------------------------------
	# 2) Jump
	#---------------------------------
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY

	#---------------------------------
	# 3) Movement input
	#---------------------------------
	var input_dir = Input.get_vector("left", "right", "forward", "backward")

	# Decide if run, crouch, or normal speed
	if Input.is_action_pressed("run") and not is_crouched:
		current_speed = RUN_SPEED
		is_walking    = false
		is_running    = true
		stamina_component.stamina_drain()
		emit_signal("stamina_change", stamina_component.stamina)
	elif Input.is_action_pressed("crouch"):
		current_speed = CROUCH_SPEED
		# If you intend to toggle crouch:
		is_crouched = !is_crouched
	else:
		current_speed = SPEED
		is_walking    = true
		is_running    = false
	
	#---------------------------------
	# 4) Rotate input by camera yaw
	#---------------------------------
	var cam_yaw = _player_pcam.global_transform.basis.get_euler().y
	move_direction = Vector3(input_dir.x, 0, input_dir.y).rotated(Vector3.UP, cam_yaw)

	#---------------------------------
	# 5) Set velocity
	#---------------------------------
	velocity.x = move_direction.x * current_speed
	velocity.z = move_direction.z * current_speed

	#---------------------------------
	# 6) Move
	#---------------------------------
	move_and_slide()
	
	#---------------------------------
	# 7) Attack logic
	#---------------------------------
	if Input.is_action_just_pressed("attack") and is_in_range:
		enemy.state = enemy.DAMAGED

	#---------------------------------
	# 8) Idle/walking/running detection
	#---------------------------------
	if move_direction.x == 0 and move_direction.z == 0:
		is_idle     = true
		is_walking  = false
		is_running  = false
	else:
		is_idle = false
	
	#---------------------------------
	# 9) Animations
	#---------------------------------
	animation_updates(current_speed, move_direction)
	
	
	if velocity.length() > 0.2:
		var cam_euler: Vector3 = _player_pcam.global_transform.basis.get_euler()
		rotation.y = lerp_angle(rotation.y, cam_euler.y, 0.1)
		
	

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var cam_rot = _player_pcam.get_third_person_rotation_degrees()
		
		# Pitch (X-axis)
		cam_rot.x -= event.relative.y * mouse_sensitivity
		cam_rot.x = clampf(cam_rot.x, min_pitch, max_pitch)

		# Yaw (Y-axis)
		cam_rot.y -= event.relative.x * mouse_sensitivity
		cam_rot.y = wrapf(cam_rot.y, min_yaw, max_yaw)

		_player_pcam.set_third_person_rotation_degrees(cam_rot)
		rotation_point.rotation_degrees = cam_rot


func _process(delta: float) -> void:
	## We just rotate the player’s Y to match camera yaw

	pass

func _on_range_body_entered(body: Node3D) -> void:
	if body.is_in_group("enemies"):
		is_in_range = true
		enemy = body
		print("INIGO MONTOYA ACTIVATED")


func _on_range_body_exited(body: Node3D) -> void:
	is_in_range = false
	print("INIGO MONTOYA DEACTIVATED")


func _on_enemy_attacking(attack: Attack) -> void:
	health_component.damage(attack)
	print("Current Health: ", health_component.get_health())


func animation_updates(current_speed, move_direction):
	if is_idle:
		ap.play("Idle(1)0")
	elif is_walking:
		ap.play("Walking(2)0")
	elif is_running:
		ap.play("Running(1)0")
