extends ActionLeaf


func tick(actor, _blackboard):
	if actor.target_reached:
		return SUCCESS
	else:
		return RUNNING
