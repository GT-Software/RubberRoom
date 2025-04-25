extends ConditionLeaf


func tick(actor, blackboard: Blackboard):
	if actor.is_in_range:
		return SUCCESS
	
	return FAILURE
	
