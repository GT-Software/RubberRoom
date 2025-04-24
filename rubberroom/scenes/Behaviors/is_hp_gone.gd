extends ConditionLeaf


func tick(actor, blackboard: Blackboard):
	if actor.health_component.get_health() <= 0:
		return SUCCESS
