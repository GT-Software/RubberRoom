extends ActionLeaf

@export var evasion_speed: float = 8.0
@export var evasion_duration: float = 2.0
@export var direction_change_interval: float = 0.5

var evasion_timer: float = 0.0
var direction_timer: float = 0.0
var current_direction: Vector3

func tick(actor: Node, blackboard: Blackboard) -> int:
	var player_position = blackboard.get_value("player_position", Vector3.ZERO)
	var actor_position = actor.global_position
	
	# Initialize evasion if just starting
	if evasion_timer <= 0:
		evasion_timer = evasion_duration
		direction_timer = 0
		current_direction = _get_evasive_direction(actor_position, player_position)
	
	# Update timers
	var delta = get_process_delta_time()
	evasion_timer -= delta
	direction_timer -= delta
	
	# Change direction periodically for serpentine movement
	if direction_timer <= 0:
		direction_timer = direction_change_interval
		current_direction = _get_evasive_direction(actor_position, player_position)
	
	# Move in evasive pattern
	if actor.has_method("set_velocity"):
		actor.set_velocity(current_direction * evasive_speed)
		actor.move_and_slide()
	elif actor.has_method("move_toward"):
		var target_pos = actor_position + current_direction * evasion_speed * delta
		actor.move_toward(target_pos, evasion_speed * delta)
	
	# Check if evasion is complete
	if evasion_timer <= 0:
		return SUCCESS
	
	return RUNNING


func _get_evasive_direction(actor_pos: Vector3, player_pos: Vector3) -> Vector3:
	# Calculate direction away from player
	var away_from_player = (actor_pos - player_pos).normalized()
	
	# Add perpednicular component for serpentine movement
	var perpendicular = Vector3(away_from_player.z, 0, -away_from_player.x)
	
	# Randomly choose left or right
	if randf() > 0.5:
		perpendicular = -perpendicular
	
	# Combine away movement with perpendicular movement
	var evasive_direction = (away_from_player + perpendicular * 0.7).normalized()
	
	return evasive_direction
