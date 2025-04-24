extends ActionLeaf


func tick(actor, blackboard: Blackboard):
	actor.queue_free()
	
	return SUCCESS
