extends ConditionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	var current_health = blackboard.get_value("health", 100.0)
	
	if current_health <= 0.0:
		return SUCCESS
	else:
		return FAILURE
