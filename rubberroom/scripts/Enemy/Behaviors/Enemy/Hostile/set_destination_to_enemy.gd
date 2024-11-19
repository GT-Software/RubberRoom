extends ActionLeaf

# Set target to player, look at player
func tick(actor, _blackboard):
	actor.update_target_location(actor.target.global_position)
	
	actor.eyes.look_at(actor.target.global_transform.origin, Vector3.UP)
	actor.rotate_y(deg_to_rad(actor.eyes.rotation.y * actor.TURN_SPEED))
	
	actor.update_nav_agent()
	return SUCCESS
