extends ConditionLeaf


func tick(actor, blackboard: Blackboard):
	if actor.current_weapon.classification == Item.Classification.SPECIAL:
		return SUCCESS
	return FAILURE
