extends ActionLeaf


func tick(actor, _blackboard):
	actor.update_target_location(actor.new_random_position())
	
	return SUCCESS
