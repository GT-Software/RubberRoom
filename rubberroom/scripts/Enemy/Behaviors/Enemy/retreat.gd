extends ActionLeaf


func tick(actor, blackboard: Blackboard):
	print(actor.name, " is retreating!")
	
	return FAILURE
