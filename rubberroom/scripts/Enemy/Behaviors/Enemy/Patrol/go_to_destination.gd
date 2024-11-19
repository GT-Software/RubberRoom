extends ActionLeaf

func tick(actor, _blackboard):
	if actor.target:
		return FAILURE
	
	actor.update_target_location(actor.random_position)
	actor.update_nav_agent()
	# Look at the direction it is moving
	actor.look_at(actor.global_position + actor.velocity)

	return SUCCESS
