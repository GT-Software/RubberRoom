extends ActionLeaf

# the actor's nav_agent target is updated with a random position defined in function new_random_position() of the actor
func tick(actor, _blackboard):
	var new_position = actor.new_random_position()
	actor.update_target_location(new_position)
	print("New patrol end location: ", new_position)
	return SUCCESS
