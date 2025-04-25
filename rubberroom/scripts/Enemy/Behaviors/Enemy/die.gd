extends ActionLeaf


func tick(actor, blackboard: Blackboard):
	print(actor.name, " has died.")
	actor.queue_free()
	
	return SUCCESS
