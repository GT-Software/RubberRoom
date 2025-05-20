extends ActionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	print("Fired Shotgun")
	return FAILURE
