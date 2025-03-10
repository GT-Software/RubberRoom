extends ActionLeaf

# Await the arrival of the actor to it's target position, return state depending on the conditions.
func tick(actor, _blackboard):
	if actor.nav_agent.is_target_reached():
		return SUCCESS
	if actor.target:
		return FAILURE
	else:
		actor.update_nav_agent()
		actor.is_idle = false
		actor.is_walking = true
		return RUNNING
