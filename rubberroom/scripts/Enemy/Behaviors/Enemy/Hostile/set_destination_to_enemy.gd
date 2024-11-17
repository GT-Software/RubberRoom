extends ActionLeaf

# Set target to player, look at player
func tick(actor, _blackboard):
	actor.update_target_location(actor.target.global_position)
	actor.look_at(actor.target.position)
	actor.update_nav_agent()
	return SUCCESS
