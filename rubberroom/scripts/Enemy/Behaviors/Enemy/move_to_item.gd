extends ActionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	if blackboard.get_value("new weapon found") == false:
		return FAILURE
	
	if actor.nav_agent.is_target_reached():
		return SUCCESS
	else:
		var location = blackboard.get_value("new weapon location")
		actor.nav_agent.update_target_location(location)
		return RUNNING
