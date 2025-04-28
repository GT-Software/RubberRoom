extends ActionLeaf


func tick(actor, blackboard: Blackboard):
	interrupt(actor, blackboard)
	return SUCCESS
