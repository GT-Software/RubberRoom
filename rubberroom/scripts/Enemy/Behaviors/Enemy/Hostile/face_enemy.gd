extends ActionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	if actor.is_in_range:
		actor.rotate_node = null
	else:
		actor.rotate_self = true
		actor.rotate_target = actor.target.global_position
		actor.rotate_node = actor.target
		
	return SUCCESS
