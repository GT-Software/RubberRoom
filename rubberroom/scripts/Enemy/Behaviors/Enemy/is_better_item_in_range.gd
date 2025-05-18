extends ConditionLeaf


func tick(actor, blackboard: Blackboard):
	if blackboard.get_value("new weapon found") == true:
		return SUCCESS
	return FAILURE
