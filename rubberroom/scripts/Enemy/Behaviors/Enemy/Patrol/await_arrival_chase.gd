extends ActionLeaf


func tick(actor, blackboard):
	# If actor reached attack location, stop moving and get ready to attack
	if actor.nav_agent.is_target_reached():
		blackboard.set_value("attacking", true)
		actor.is_running = false
		actor.is_idle = false
		actor.is_walking = false
		actor.current_speed = 0
		actor.update_animation_state()
		return FAILURE
	# Otherwise, keep moving towards that location
	else:
		actor.update_target_location(blackboard.get_value("player_pos"), 5.0)
		actor.is_idle = false
		actor.is_walking = false
		actor.is_running = true
		actor.current_speed = actor.RUN_SPEED
		blackboard.set_value("at cover", false)
		blackboard.set_value("attacking", false)
		return RUNNING

func interrupt(actor: Node, blackboard: Blackboard) -> void:
	print("Await Arrival interrupted!")
