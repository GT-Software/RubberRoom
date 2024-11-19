extends ActionLeaf


func tick(actor, _blackboard):
	if actor.target:
		return FAILURE
	
	actor.new_random_position()
	
	return SUCCESS
