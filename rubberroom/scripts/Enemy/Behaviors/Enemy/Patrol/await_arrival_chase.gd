extends ActionLeaf


func tick(actor, blackboard):
	if actor.is_in_range or actor.nav_agent.is_target_reached():
		#blackboard.set_value('attacking', true)
		actor.update_target_location(actor.global_position)
		actor.is_running = false
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

func interrupt(actor: Node, blackboard: Blackboard) -> void:
	var enemy = actor as Enemy
	# Stop the chase animation
	actor.is_running = false
	actor.is_running = false
	actor.update_animation_state()
	actor.velocity = Vector3.ZERO
	actor.nav_agent.set_velocity(Vector3.ZERO)
	print("Await Arrival interrupted!")
