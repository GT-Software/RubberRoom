extends ConditionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	if actor.current_weapon == null:
		return SUCCESS
	else:
		return FAILURE
