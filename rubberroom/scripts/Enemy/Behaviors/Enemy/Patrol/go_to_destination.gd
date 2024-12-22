extends ActionLeaf

func tick(actor, _blackboard):
	actor.update_target_location(actor.target.global_position)
	actor.update_nav_agent()

	return SUCCESS
