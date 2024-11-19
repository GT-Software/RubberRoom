extends CharacterBody3D
class_name Enemy

# AMONGUS?????
signal attacking(attack : Attack)

@onready var nav_agent = $NavigationAgent3D
@onready var detection_area = $DetectionArea
@onready var player = %Player
@onready var eyes = $Eyes
@onready var raycast = $"Line of Sight"
@onready var random_position = Vector3(randf_range(-45, 45), position.y, randf_range(-45, 45))

@export var SPEED = 3.0
@export var RUN_SPEED = 60.0
@export var TURN_SPEED = 2.0
@export var current_speed : float

var is_spotted : bool = false
var is_chasing : bool = false
var is_in_range : bool = false
var is_alive : bool = true
var on_attack_cooldown : bool = false
var health_component : HealthComponent
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var target = null


func _ready():
	current_speed = SPEED
	is_chasing = false
	health_component = HealthComponent.new()
	detection_area.connect('is_detected', alert)


func _physics_process(delta: float):
	if !is_alive:
		return
		
	velocity.y -= gravity * delta

# Idle state
func idle():
	# Stop moving
	current_speed = 0

# Rotate eyes to target position
func rotate_to_look():
	var random_direction = Vector3(
		randf_range(-1.0, 1.0),  # Random x direction
		randf_range(-1.0, 1.0),  # Random y direction
		randf_range(-1.0, 1.0)   # Random z direction
	).normalized()  # Normalize to make sure the vector has length 1
	
	# Get the target position relative to eyes
	var target_position = eyes.global_transform.origin + random_direction * 10.0  # Scale to make sure the target is far enough
	
	eyes.look_at(target_position, Vector3.UP)
	rotate_y(deg_to_rad(eyes.rotation.y * TURN_SPEED))


func new_random_position():
	if (abs(random_position.x - global_position.x) <= 5 and abs(random_position.z - global_position.z) <= 5):
		# Choose a random position relative to the player, so it does not seem like the enemy is actually chasing the player.
		# TODO I want to change this so it is not going long distances, only staying within a certain area
		random_position = Vector3(randf_range(player.position.x - 40, player.global_position.x + 40), position.y, randf_range(player.position.z - 40, player.global_position.z + 40))
		# Clamps the random position to the boundaries of the world (currently 100, 100 subtract by 5 for wiggle room)
		clamp(random_position.x, -40, 40)
		clamp(random_position.z, -40, 40)


func alert(new_target):
	target = new_target


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
	print(self.name + ": Updating enemy target location...")
	nav_agent.target_position = target_location

# If the enemy has reached its target, stop moving
func _on_navigation_agent_3d_target_reached() -> void:
	print(self.name + ": Target reached.")
	nav_agent.set_velocity(Vector3.ZERO)

# Set velocity to a safe velocity for moving around enemies (must adjust)
func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	velocity = velocity.move_toward(safe_velocity, .25)
	move_and_slide()
