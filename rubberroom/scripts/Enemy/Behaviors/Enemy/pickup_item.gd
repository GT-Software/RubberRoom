extends ActionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	blackboard.set_value("new weapon found", false)
	return FAILURE
