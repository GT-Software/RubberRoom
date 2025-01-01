extends ActionLeaf


func tick(actor, _blackboard):
	if actor.is_in_range or actor.nav_agent.is_target_reached():
		_blackboard.set_value('attacking', true)
		return FAILURE
	elif actor.target == null:
		_blackboard.set_value('attacking', false)
		return FAILURE
	else:
		actor.update_target_location(actor.target.position)
		actor.update_nav_agent()
		return RUNNING
