extends ActionLeaf


func tick(actor, _blackboard):
	actor.new_random_position()
	
	return SUCCESS
