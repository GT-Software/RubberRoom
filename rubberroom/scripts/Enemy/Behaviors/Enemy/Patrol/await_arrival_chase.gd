extends ActionLeaf


func tick(actor, _blackboard):
	if actor.is_in_range:
		return FAILURE
	elif actor.target == null:
		return SUCCESS
	else:
		actor.update_target_location(actor.target.position)
		actor.update_nav_agent()
		return RUNNING
