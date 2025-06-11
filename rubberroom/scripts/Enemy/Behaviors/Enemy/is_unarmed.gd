extends ConditionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	if actor.current_weapon.classification == Item.Classification.UNARMED:
		return SUCCESS
	else:
		return FAILURE
