extends ConditionLeaf


func tick(actor, blackboard: Blackboard):
	if blackboard.get_value("is_attacked") == true:
		return SUCCESS
	return FAILURE
