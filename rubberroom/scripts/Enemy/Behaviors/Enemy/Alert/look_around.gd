extends ActionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	actor.rotate_to_look()
	
	return SUCCESS
