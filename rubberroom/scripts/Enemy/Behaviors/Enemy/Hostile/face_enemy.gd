extends ActionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	if actor.is_in_range:
		actor.rotate_node = null
		return FAILURE
	else:
		actor.rotate_self = true
		actor.rotate_target = blackboard.get_value("player_pos")
		actor.rotate_node = actor.target
		
	return SUCCESS

func interrupt(actor: Node, blackboard: Blackboard) -> void:
	print("Face enemy interrupted")
