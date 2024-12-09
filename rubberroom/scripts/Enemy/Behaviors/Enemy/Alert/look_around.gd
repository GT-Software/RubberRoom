extends ActionLeaf

# TODO: rotate_to_look() function runs too quickly, needs to check if its at the rotation before leaving this actionleaf

func tick(actor: Node, blackboard: Blackboard) -> int:
	actor.rotate_to_look()
	
	return SUCCESS
