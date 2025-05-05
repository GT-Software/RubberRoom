extends ActionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	actor.update_target_location(blackboard.get_value("safe_position"))
	
	return SUCCESS
