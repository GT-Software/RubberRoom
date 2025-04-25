extends ConditionLeaf


func tick(actor, blackboard: Blackboard):
	if actor.health_component.get_health() < actor.health_component.get_max_health() / 2.0:
		return SUCCESS
		
	return FAILURE
