extends ActionLeaf

@export var dodge_trigger_parameter: String

@export var dodge_duration: float = 0.6
@export var dodge_distance: float = 4.0
@export var dodge_speed: float = 12.0
@export var iframe_duration: float = 0.3  # Invincibility frames

enum DodgeDirection {
	BACKWARD,
	LEFT,
	RIGHT,
	RANDOM_SIDE
}

@export var preferred_dodge_direction: DodgeDirection = DodgeDirection.RANDOM_SIDE

var dodge_timer: float = 0.0
var dodge_started: bool = false
var dodge_direction: Vector3
var initial_position: Vector3
var target_position: Vector3
var iframe_timer: float = 0.0

func tick(actor: Node, blackboard: Blackboard) -> int:
	var delta = get_process_delta_time()
	
	# Start dodge if not already started
	if not dodge_started:
		start_dodge(actor, blackboard)
		dodge_started = true
		dodge_timer = dodge_duration
		iframe_timer = iframe_duration
		
	# Update timers
	dodge_timer -= delta
	iframe_timer -= delta
	
	# Update invincibility frames
	if iframe_timer > 0:
		blackboard.set_value("is_invinvible", true)
	else:
		blackboard.set_value("is_invincible", false)
	
	# Execute dodge movement
	execute_dodge_movement(actor, blackboard, delta)
	
	# Check if dodge is complete
	if dodge_timer <= 0:
		complete_dodge(actor, blackboard)
		return SUCCESS
	
	return RUNNING


func start_dodge(actor: Node, blackboard: Blackboard) -> void:
	print("Starting dodge maneuver")
	
	# Set dodge cooldown
	blackboard.set_value("dodge_cooldown", 2.0) # Reset cooldown
	
	# Calculate dodge direction
	dodge_direction = calculate_dodge_direction(actor, blackboard)
	initial_position = actor.global_position
	target_position = initial_position + (dodge_direction * dodge_distance)
	
	# Check if target position is valid (not into walls)
	target_position = validate_dodge_position(actor, target_position)
	
	# Trigger dodge animation here
	
	print("Triggering dodge animation")
	
	# Play dodge sound if any
	
	# Dodge effects if any


func calculate_dodge_direction(actor: Node, blackboard: Blackboard) -> Vector3:
	var incoming_attack_direction = blackboard.get_value("incoming_attack_direction", Vector3.ZERO)
	var player_position = blackboard.get_value("player_postion", Vector3.ZERO)
	var actor_position = actor.global_position
	
	match preferred_dodge_direction:
		DodgeDirection.BACKWARD:
			# Dodge away from player
			return (actor_position - player_position).normalized()
		DodgeDirection.LEFT:
			# Dodge to the left relative to player's attack direction
			if incoming_attack_direction != Vector3.ZERO:
				return incoming_attack_direction.rotated(Vector3.UP, PI/2).normalized()
			else:
				return actor.global_transform.basis.x.normalized()
		DodgeDirection.RIGHT:
			# Dodge to the right relative to player's attack direction
			if incoming_attack_direction != Vector3.ZERO:
				return incoming_attack_direction.rotated(Vector3.UP, -PI/2).normalized()
			else:
				return actor.global_transform.basis.x.normalized()
		DodgeDirection.RANDOM_SIDE:
			# Randomly choose left or right
			var side_multiplier = 1 if randf() > 0.5 else -1
			if incoming_attack_direction != Vector3.ZERO:
				return incoming_attack_direction.rotated(Vector3.UP, PI/2 * side_multiplier).normalized()
			else:
				return actor.global_transform.basis.x.normalized() * side_multiplier
	
	# Fallback: dodge backward
	return (actor_position - player_position).normalized()


func validate_dodge_position(actor: Node, target_pos: Vector3) -> Vector3:
	# Raycast to check if dodge position is clear
	var space_state = actor.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		actor.global_position + Vector3(0, 0.5, 0),	# Again, values can be modified
		target_pos + Vector3(0, 0.5, 0)	# Again, values can be modified
	)
	query.exclude = [actor]
	
	var result = space_state.intersect_ray(query)
	
	if not result.is_empty():
		# Hit something, try shorter dodge distance
		var hit_point = result.get("position", target_pos)
		var safe_distance = actor.global_position.distance_to(hit_point) * 0.8
		return actor.global_position + (dodge_direction * safe_distance)
	
	return target_pos


func execute_dodge_movement(actor: Node, blackboard: Blackboard, delta: float) -> void:
	if not actor.has_method("set_velocity"):
		return
	
	# Calculate movement progress
	var progress = 1.0 - (dodge_timer / dodge_duration)
	
	# Use smooth curve for more natural movement
	var smooth_progress = ease_out_quad(progress)
	
	# Calculate current target position
	var current_target = initial_position.lerp(target_position, smooth_progress)
	
	# Calculate velocity needed to reach target
	var velocity_direction = (current_target - actor.global_position).normalized()
	var velocity = velocity_direction * dodge_speed
	
	# Apply velocity
	actor.set_velocity(velocity)


func ease_out_quad(t: float) -> float:
	return 1 - (1 - t) * (1 - t)


func complete_dodge(actor: Node, blackboard: Blackboard) -> void:
	print("Dodge complete")
	
	# Clear dodge animation state here
	
	# Clear invincibility
	blackboard.set_value("is_invincible", false)
	
	# Reset for next use
	dodge_started = false
	
	# Stop movement
	if actor.has_method("set_velocity"):
		actor.set_velocity(Vector3.ZERO)
