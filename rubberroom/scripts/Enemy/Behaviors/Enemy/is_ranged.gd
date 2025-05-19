extends ConditionLeaf


func tick(actor, blackboard: Blackboard):
	if actor.current_weapon.classification == Item.Classification.RANGED:
		return SUCCESS
	return FAILURE
