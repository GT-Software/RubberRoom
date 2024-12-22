extends ActionLeaf


func tick(actor, _blackboard):
	if actor.is_in_range:
		return FAILURE
	else:
		actor.update_target_location(actor.target.global_position)
		actor.update_nav_agent()
		return RUNNING
