extends ActionLeaf


func tick(actor, _blackboard):
	if actor.is_in_range or actor.nav_agent.is_target_reached():
		return SUCCESS
	if actor.target:
		return FAILURE
	else:
		actor.update_nav_agent()
		return RUNNING
