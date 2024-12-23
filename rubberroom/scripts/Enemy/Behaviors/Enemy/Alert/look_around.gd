extends ActionLeaf

# TODO: rotate_to_look() function runs too quickly, needs to check if its at the rotation before leaving this actionleaf

func tick(actor: Node, blackboard: Blackboard) -> int:
	if actor.raycast.get_collider() == actor.target:
		return FAILURE
	else:
		actor.rotate_self = true
		actor.rotate_target = actor.new_random_position()
		actor.rotate_node = actor.target
		return RUNNING
		
	return SUCCESS
