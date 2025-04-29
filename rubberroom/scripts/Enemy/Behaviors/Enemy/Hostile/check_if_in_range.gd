extends ConditionLeaf


func tick(actor, _blackboard):
	if actor.target:
		return SUCCESS
	return FAILURE
