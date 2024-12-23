extends ActionLeaf

func tick(actor, _blackboard):
	if actor.target:
		actor.update_nav_agent()

	return SUCCESS
