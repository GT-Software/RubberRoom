class_name Enemy
extends CharacterBody3D

# Enemy States: Chase, Patrol, Alert, Attack, Idle
enum enemy_states {
	IDLE,
	PATROL,
	ALERT,
	CHASE,
	ATTACK,
	STUNNED,
	PAUSED
}

@onready var nav_agent = $NavigationAgent3D
@onready var detection_area = $DetectionArea
@onready var player = %Player
@onready var patrol_timer = $PatrolTimer
@onready var huh_timer = $HuhTimer
# Numbers should be borders of the map, but that would change depending on the room the enemy is in
@onready var random_position = Vector3(randf_range(-45, 45), position.y, randf_range(-45, 45))

@export var SPEED = 3
@export var current_speed : float
@export var is_idle : bool
var state : enemy_states
var is_chasing : bool

func _ready():
	current_speed = SPEED
	is_chasing = false

func _process(delta):
	
	# For animations when needed
	match state:
		enemy_states.IDLE:
			pass
		enemy_states.ALERT:
			pass
		enemy_states.PATROL:
			pass
		enemy_states.CHASE:
			pass
		enemy_states.ATTACK:
			pass
		enemy_states.STUNNED:
			pass
		enemy_states.PAUSED:
			pass


func _physics_process(delta: float):
	# If the is_idle variable is true, don't do nuffin
	# If the enemy state is paused, don't do nuffin
	if is_idle or state == enemy_states.PAUSED:
		return
		
	# Once the player is detected in the detection_area, chase the player
	if detection_area.detected:
		state = enemy_states.CHASE
		current_speed = SPEED
		chase()
	# If the player is no longer detected and the enemy is still chasing,
	# Tell the enemy to stop chasing and set a timer for a brief pause
	elif !detection_area.detected and is_chasing:
		state = enemy_states.PAUSED
		is_chasing = false
		current_speed = 0
		nav_agent.target_position = global_position
		huh_timer.start(huh_timer.wait_time)
	else:
		current_speed = SPEED
		state = enemy_states.PATROL
		patrol()
		
	update_nav_agent()
	

# If the enemy detects you, it'll start chasing you (enemy state)
func chase():
	is_chasing = true
	look_at(player.position)
	nav_agent.target_position = player.global_position
	update_nav_agent()

# Default enemy state, enemy is patrolling the area (right now does nothing)
func patrol():
	look_at(global_transform.origin + velocity)
	nav_agent.target_position = random_position
	update_nav_agent()
	if (abs(random_position.x - global_position.x) <= 5 and abs(random_position.z - global_position.z) <= 5 or patrol_timer.time_left == 0):
		random_position = Vector3(randf_range(player.position.x - 40, player.global_position.x + 40), position.y, randf_range(player.position.z - 40, player.global_position.z + 40))
		clamp(random_position.x, -45, 45)
		clamp(random_position.z, -45, 45)
	patrol_timer.start(patrol_timer.wait_time)

# Update the current path and velocity
func update_nav_agent():
	var next_location = nav_agent.get_next_path_position()
	var current_location = global_transform.origin
	var new_velocity = (next_location - current_location).normalized() * current_speed
	
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
	state = enemy_states.PATROL
