extends CharacterBody3D
class_name Enemy

# AMONGUS?????
signal attacking(attack : Attack)

# Scene reference variables

@onready var nav_agent = $NavigationAgent3D
@onready var detection_area = $DetectionArea
@onready var player = %Player
@onready var eyes = $Eyes
@onready var raycast = $"Line of Sight"

# Export variables

@export var SPEED = 3.0
@export var RUN_SPEED = 60.0
@export var TURN_SPEED = 2.0
@export var current_speed : float

# Boolean variables

var is_spotted : bool = false
var is_chasing : bool = false
var is_in_range : bool = false
var is_alive : bool = true
var on_attack_cooldown : bool = false
var rotate_self : bool = true

var health_component : HealthComponent
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var target = null
var rotate_node : Node3D = null
var rotate_target : Vector3 = Vector3.ZERO


func _ready():
	current_speed = SPEED
	is_chasing = false
	health_component = HealthComponent.new()
	detection_area.connect('is_detected', alert)


func _physics_process(delta: float):
	if !is_alive:
		return
		
	velocity.y -= gravity * delta
	
	if rotate_self:
		if rotate_node != null:
			rotate_target = rotate_node.global_position
		else:
			rotate_target = nav_agent.get_next_path_position()
		rotate_to_look(rotate_target, delta)

# Idle state
func idle():
	# Stop moving
	current_speed = 0

# Rotate eyes to target position
func rotate_to_look(pos : Vector3, _delta : float):
	# optional, makes the enemy not rotate vertically
	pos.y = global_position.y
	
	# If the rotation is reached, return
	if global_transform.origin.is_equal_approx(pos) or pos == Vector3.ZERO:
		return
		
	
	# Smoothly rotate to look at next path position
	global_transform.basis = global_transform.basis.slerp(global_transform.looking_at(pos, Vector3.UP).basis, _delta * TURN_SPEED)

func new_random_position() -> Vector3:
	var random_position : Vector3
	
	# Choose a random position relative to the player, so it does not seem like the enemy is actually chasing the player.
	random_position = Vector3(randf_range(player.position.x - 40, player.global_position.x + 40), position.y, randf_range(player.position.z - 40, player.global_position.z + 40))
	# Clamps the random position to the boundaries of the world (currently 100, 100 subtract by 5 for wiggle room)
	random_position.x = clamp(random_position.x, -40, 40)
	random_position.z = clamp(random_position.z, -40, 40)
	
	return random_position


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
