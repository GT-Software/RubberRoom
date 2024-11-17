extends ActionLeaf

func tick(actor, _blackboard):
	actor.update_target_location(actor.random_position)
	actor.update_nav_agent()
	# Look at the direction it is moving
	actor.look_at(actor.global_transform.origin + actor.velocity)
	return SUCCESS
