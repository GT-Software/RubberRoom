extends CharacterBody3D
class_name Enemy


# AMONGUS?????
signal attacking(attack : Attack)

@onready var nav_agent = $NavigationAgent3D

@onready var detection_area = $DetectionArea
@onready var player = %Player
@onready var eyes = $Eyes
@onready var raycast = $"Line of Sight"

@onready var patrol_timer = $PatrolTimer
@onready var huh_timer = $HuhTimer
@onready var alert_timer = $AlertTimer
@onready var delay_timer: Timer = $DelayTimer

# Numbers should be borders of the map, but that would change depending on the room the enemy is in
@onready var random_position = Vector3(randf_range(-45, 45), position.y, randf_range(-45, 45))

@export var SPEED = 3.0
@export var RUN_SPEED = 60.0
@export var TURN_SPEED = 2.0
@export var current_speed : float
@export var is_idle : bool
var is_spotted : bool = false
var is_chasing : bool = false
var is_in_range : bool = false
var is_alive : bool = true
var target_reached : bool = false
var on_attack_cooldown : bool = false

var health_component : HealthComponent


var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var target

func _ready():
	current_speed = SPEED
	is_chasing = false
	health_component = HealthComponent.new()

func _physics_process(delta: float):
	if !is_alive:
		return
		
	velocity.y -= gravity * delta

# Idle state
func idle():
	# Stop moving
	current_speed = 0


func new_random_position():
	if (abs(random_position.x - global_position.x) <= 5 and abs(random_position.z - global_position.z) <= 5):
		# Choose a random position relative to the player, so it does not seem like the enemy is actually chasing the player.
		# TODO I want to change this so it is not going long distances, only staying within a certain area
		random_position = Vector3(randf_range(player.position.x - 40, player.global_position.x + 40), position.y, randf_range(player.position.z - 40, player.global_position.z + 40))
		# Clamps the random position to the boundaries of the world (currently 100, 100 subtract by 5 for wiggle room)
		clamp(random_position.x, -40, 40)
		clamp(random_position.z, -40, 40)

func alert():
	alert_timer.start()
	# Stop MOVING here
	update_target_location(global_position)
	current_speed = 0.5
	update_nav_agent()
	
	target = detection_area.target
	eyes.look_at(target.global_transform.origin, Vector3.UP)
	rotate_y(deg_to_rad(eyes.rotation.y * TURN_SPEED))
	
	var hit = raycast.get_collider()
	
	if hit == player:
		print("My name is Inigo Montoya! You killed my father! Prepare to die!")
		is_spotted = true

func attack():
	var attack : Attack = Attack.new()
	emit_signal("attacking", attack)

func take_damage(attack : Attack):
	health_component.damage(attack)


# Update the current path and velocity
func update_nav_agent():
	var next_location = nav_agent.get_next_path_position()
	var current_location = global_transform.origin
	var new_velocity = (next_location - current_location).normalized() * current_speed
	
	# Sets the velocity value for the nav_agent to calculate a safe direction (see _on_navigation_agent_3d_velocity_computed
	nav_agent.set_velocity(new_velocity)
	
# Updates the Navigation Agent's targetted vector position
func update_target_location(target_location) -> void:
	target_reached = false
	nav_agent.target_position = target_location
	
# If the enemy has reached its target, stop moving
func _on_navigation_agent_3d_target_reached() -> void:
	nav_agent.set_velocity(Vector3.ZERO)
	target_reached = true

# Set velocity to a safe velocity for moving around enemies (must adjust)
func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	velocity = velocity.move_toward(safe_velocity, .25)
	move_and_slide()
