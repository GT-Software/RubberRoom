extends ConditionLeaf


func tick(actor, _blackboard):
	print("Enemy: Checking if in range")
	
	if actor.is_in_range:
		return SUCCESS
		
	return FAILURE
