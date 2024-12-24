extends ActionLeaf

# Update the actor's nav agent to create a path to the new target position
func tick(actor, _blackboard):
	actor.update_nav_agent()

	return SUCCESS
