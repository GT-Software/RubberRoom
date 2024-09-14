class_name Enemy
extends CharacterBody3D

@onready var nav_agent = $NavigationAgent3D
@onready var detection_area = $DetectionArea
@onready var player = %Player

@export var SPEED = 3

var is_chasing = false

func _physics_process(delta: float):
	if detection_area.detected:
		chase()
	elif !detection_area.detected and is_chasing:
		go_to_last_known_position()
		is_chasing = false
	else:
		patrol()
		

# If the enemy detects you, it'll start chasing you (enemy state)
func chase():
	look_at(player.position)
	nav_agent.target_position = player.global_position
	update_nav_agent()
	is_chasing = true

# Default enemy state, enemy is patrolling the area (right now does nothing)
func patrol():
	pass

# Update the current path and velocity
func update_nav_agent():
	var next_location = nav_agent.get_next_path_position()
	var current_location = global_transform.origin
	var new_velocity = (next_location - current_location).normalized() * SPEED
	
	nav_agent.set_velocity(new_velocity)
	
# Updates the Navigation Agent's targetted vector position
func update_target_location(target_location) -> void:
	nav_agent.target_position = target_location

# Change the target position to the player's last known position
func go_to_last_known_position():
	update_target_location(detection_area.last_position)
	if nav_agent.is_target_reached():
		nav_agent.set_velocity(Vector3.ZERO)
	
# If the enemy has reached its target, print in range for now (see NavigationAgent3D's Target Desired Distance)
func _on_navigation_agent_3d_target_reached() -> void:
	print("in range")

# Set velocity to a safe velocity for moving around enemies (must adjust)
func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	velocity = velocity.move_toward(safe_velocity, .25)
	move_and_slide()
