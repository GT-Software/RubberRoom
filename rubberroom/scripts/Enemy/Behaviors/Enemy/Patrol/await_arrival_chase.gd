extends ActionLeaf


func tick(actor, blackboard):
	if actor.is_in_range or actor.nav_agent.is_target_reached():
		#blackboard.set_value('attacking', true)
		return FAILURE
	else:
		actor.update_target_location(blackboard.get_value("player_pos"))
		#actor.update_nav_agent(actor.RUN_SPEED)
		actor.is_idle = false
		actor.is_walking = false
		actor.is_running = true
		actor.current_speed = actor.RUN_SPEED
		blackboard.set_value("at cover", false)
		return RUNNING
