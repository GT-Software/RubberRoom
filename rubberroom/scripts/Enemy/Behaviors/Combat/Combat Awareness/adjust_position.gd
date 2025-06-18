extends ActionLeaf

@export var adjustment_speed: float = 3.0
@export var optimal_combat_distance: float = 5.0

func tick(actor: Node, blackboard: Blackboard) -> int:
	var player_position = blackboard.get_value("player_position", Vector3.ZERO)
	var player_distance = blackboard.get_value("player_distance", 999.0)
	var threat_level = blackboard.get_value("current_threat_level", 0.0)
	
	# Adjust position baased on threat level and combat preferences
	var adjustment_direction = Vector3.ZERO
	
	if player_distance < optimal_combat_distance * 0.7:
		# Too close, back away
		adjustment_direction = (actor.global_position - player_position).normalized()
	elif player_distance > optimal_combat_distance * 1.3:
		# Too far, move closer
		adjustment_direction = (player_position - actor.global_position).normalized()
	else:
		# Strafe to avoid being a sitting duck
		var perpendicular = Vector3(player_position.z - actor.global_position.z, 0, actor.global_position.x - player_position.x).normalized()
		adjustment_direction = perpendicular * (1.0 if randf() > 0.5 else -1.0)
	
	# Apply movement
	if adjustment_direction != Vector3.ZERO:
		if actor.has_method("set_velocity"):
			var current_velocity = actor.velocity if actor.has_method("get_velocity") else Vector3.ZERO
			var adjustment_velocity = adjustment_direction * adjustment_speed * threat_level
			actor.set_velocity(current_velocity + adjustment_velocity)
			actor.move_and_slide()
		
	return SUCCESS
