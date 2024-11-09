class_name Enemy
extends CharacterBody3D

# AMONGUS?????

@onready var nav_agent = $NavigationAgent3D

@onready var detection_area = $DetectionArea
@onready var player = %Player
@onready var eyes = $Eyes
@onready var raycast = $"Line of Sight"

@onready var patrol_timer = $PatrolTimer
@onready var huh_timer = $HuhTimer
@onready var alert_timer = $AlertTimer

# Numbers should be borders of the map, but that would change depending on the room the enemy is in
@onready var random_position = Vector3(randf_range(-45, 45), position.y, randf_range(-45, 45))

@export var SPEED = 3.0
@export var RUN_SPEED = 60.0
@export var TURN_SPEED = 2.0
@export var current_speed : float
@export var is_idle : bool
var is_spotted : bool = false

# Enemy States: Chase, Patrol, Alert, Attack, Idle
enum {
	IDLE = 0,
	PATROL = 1,
	ALERT = 2,
	CHASE = 3,
	ATTACK = 4,
	STUNNED = 5,
	PAUSED = 6
}

@export var state = IDLE
var is_chasing : bool
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var target

func _ready():
	current_speed = SPEED
	is_chasing = false

func _physics_process(delta: float):
	#print(state)
	#print(current_speed)
	
	# animations when needed
	match state:
		IDLE:	# 0
			pass
		ALERT: # 2
			alert()
		PATROL: # 1
			patrol()
		CHASE: # 3
			chase()
		ATTACK: # 4
			pass
		STUNNED: # 5
			pass
		PAUSED: # 6
			paused()
	
	
	# Idle state (TODO)
	
	# Once the player is in the detection collision sphere, this condition is true
	if detection_area.detected and not is_spotted:
		# Alert
		state = 2
	# If the player is no longer detected and the enemy is still chasing,
	# Tell the enemy to stop chasing and set a timer for a brief pause
	elif !detection_area.detected and is_chasing:
		state = PAUSED
		is_chasing = false
		is_spotted = false
		current_speed = 0
		nav_agent.target_position = global_position
	# Patrol state
	elif !detection_area.detected and not is_spotted:
		current_speed = SPEED
		state = PATROL
	

	velocity.y -= gravity * delta
	update_nav_agent()
	

func paused():
	huh_timer.start()

# If the enemy detects you, it'll start chasing you (enemy state)
func chase():
	is_chasing = true
	current_speed = RUN_SPEED
	# Look at the player
	look_at(player.position)
	# Set the nav agent's target to the player
	nav_agent.target_position = player.global_position
	# Update the nav agent
	update_nav_agent()

# Default enemy state, enemy is patrolling the area (right now does nothing)
func patrol():
	# Look at the direction it is moving
	look_at(global_transform.origin + velocity)
	# Set target to random position
	update_target_location(random_position)
	# Update the nav agent
	update_nav_agent()
	# This math decides when and where the enemy is patrolling
	if (abs(random_position.x - global_position.x) <= 5 and abs(random_position.z - global_position.z) <= 5 or patrol_timer.time_left == 0):
		# Choose a random position relative to the player, so it does not seem like the enemy is actually chasing the player.
		random_position = Vector3(randf_range(player.position.x - 40, player.global_position.x + 40), position.y, randf_range(player.position.z - 40, player.global_position.z + 40))
		# Clamps the random position to the boundaries of the world (currently 100, 100 subtract by 5 for wiggle room)
		clamp(random_position.x, -45, 45)
		clamp(random_position.z, -45, 45)
	patrol_timer.start(patrol_timer.wait_time)


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
		state = CHASE
		is_spotted = true
	


# Update the current path and velocity
func update_nav_agent():
	var next_location = nav_agent.get_next_path_position()
	var current_location = global_transform.origin
	var new_velocity = (next_location - current_location).normalized() * current_speed
	
	# Sets the velocity value for the nav_agent to calculate a safe direction (see _on_navigation_agent_3d_velocity_computed
	nav_agent.set_velocity(new_velocity)
	
# Updates the Navigation Agent's targetted vector position
func update_target_location(target_location) -> void:
	nav_agent.target_position = target_location
	
# If the enemy has reached its target, print in range for now (see NavigationAgent3D's Target Desired Distance)
func _on_navigation_agent_3d_target_reached() -> void:
	print("in range")

# Set velocity to a safe velocity for moving around enemies (must adjust)
func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	velocity = velocity.move_toward(safe_velocity, .25)
	move_and_slide()


func _on_huh_timer_timeout() -> void:
	print("Confusion Escalating to patrol")
	#state = PATROL


func _on_alert_timer_timeout() -> void:
	print("I have been alerted to your position!")
