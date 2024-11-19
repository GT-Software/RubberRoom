extends ActionLeaf


func tick(actor, _blackboard):
	if actor.target:
		return FAILURE
	
	if actor.nav_agent.is_target_reached():
		return SUCCESS
	else:
		actor.update_nav_agent()
		return RUNNING
