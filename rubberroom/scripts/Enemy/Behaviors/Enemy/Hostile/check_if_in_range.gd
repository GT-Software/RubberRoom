extends ConditionLeaf


func tick(actor, _blackboard):
	if actor.target and actor.is_in_range:
		return SUCCESS
	return FAILURE
