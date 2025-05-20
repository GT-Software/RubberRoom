extends ConditionLeaf


func tick(actor, blackboard: Blackboard):
	if actor.current_weapon.classification == 3:
		return SUCCESS
	return FAILURE
