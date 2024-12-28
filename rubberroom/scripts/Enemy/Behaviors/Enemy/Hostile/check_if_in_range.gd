extends ConditionLeaf


func tick(actor, _blackboard):
	print("Enemy: Checking if in range")
	
	if actor.is_in_range or actor.nav_agent.is_target_reached():
		return SUCCESS
		
	return FAILURE
