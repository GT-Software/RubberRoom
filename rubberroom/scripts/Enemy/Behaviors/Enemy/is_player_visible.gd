extends ConditionLeaf


func tick(actor, blackboard: Blackboard):
	if blackboard.get_value("can_see_player") == true:
		return SUCCESS
	return FAILURE
	
