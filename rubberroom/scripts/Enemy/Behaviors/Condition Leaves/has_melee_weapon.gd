extends ConditionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	var current_weapon = blackboard.get_value("current_weapon", null)
	
	if current_weapon and current_weapon.has_method("is_melee") and current_weapon.is_melee():
		return SUCCESS
	else:
		return FAILURE
