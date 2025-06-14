extends ConditionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	var current_weapon = blackboard.get_value("current_weapon", null)
	var ammo_manager = blackboard.get_value("ammo_manager", null)
	
	return FAILURE
