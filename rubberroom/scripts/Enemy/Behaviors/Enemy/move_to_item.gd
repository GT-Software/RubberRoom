extends ActionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	if blackboard.get_value("new weapon found") == false:
		return FAILURE
	
	if actor.nav_agent.is_target_reached():
		actor.is_walking = false
		
		return SUCCESS
	else:
		var location = blackboard.get_value("new weapon location")
		actor.update_target_location(location)
		actor.current_speed = actor.SPEED
		
		actor.is_walking = true
		actor.is_running = false
		actor.is_idle = false
		return RUNNING
