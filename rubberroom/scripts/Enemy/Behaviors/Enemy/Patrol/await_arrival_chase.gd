extends ActionLeaf


func tick(actor, blackboard):
	if actor.is_in_range or actor.nav_agent.is_target_reached():
		#blackboard.set_value('attacking', true)
		return FAILURE
	elif actor.target == null:
		#blackboard.set_value('attacking', false)
		return FAILURE
	else:
		actor.update_target_location(actor.target.position)
		actor.update_nav_agent(actor.RUN_SPEED)
		actor.is_idle = false
		actor.is_walking = false
		actor.is_running = true
		blackboard.set_value("at cover", false)
		return RUNNING
