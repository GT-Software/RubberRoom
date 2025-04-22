extends ConditionLeaf


func tick(actor, blackboard: Blackboard):
	if blackboard.get_value("at cover") == true:
		return FAILURE
	
	return SUCCESS
