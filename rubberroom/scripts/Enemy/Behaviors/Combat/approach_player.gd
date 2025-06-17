extends ActionLeaf

@export var approach_speed: float = 5.0
@export var stop_distance: float = 2.0

func tick(actor: Node, blackboard: Blackboard) -> int:
	var navigation_agent = actor.nav_agent
	
	var player_position = blackboard.get_value("player_position", Vector3.ZERO)
	var player_distance = blackboard.get_value("player_distance", 999.0)
	
	# Stop if close enough
	if player_distance <= stop_distance:
		return SUCCESS
	
	# Set navigation target
	actor.update_target_location(player_position)
	
	# Move towards player
	if not navigation_agent.is_navigation_finished():
		var next_position = navigation_agent.get_next_path_position()
		var direction = (next_position - actor.global_position).normalized()
		
		if actor.has_method("set_velocity"):
			actor.set_velocity(direction * approach_speed)
			actor.move_and_slide()
		
		return RUNNING
	
	return SUCCESS
