extends ConditionLeaf


func tick(actor, blackboard: Blackboard):
	if blackboard.get_value("is shot at") == true:
		return SUCCESS
		
	return FAILURE
