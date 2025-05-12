extends ActionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	if actor.is_in_range or actor.nav_agent.is_target_reached():
		#blackboard.set_value('attacking', true)
		actor.update_target_location(actor.global_position)
		actor.is_running = false
		actor.is_idle = false
		actor.is_walking = false
		actor.current_speed = 0
		return FAILURE
	else:
		actor.update_target_location(blackboard.get_value("player_pos"), 0.6)
		#actor.update_nav_agent(actor.RUN_SPEED)
		actor.is_idle = false
		actor.is_walking = true
		actor.is_running = false
		actor.current_speed = actor.SPEED
		return RUNNING
