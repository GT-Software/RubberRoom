extends ConditionLeaf


func tick(actor, blackboard: Blackboard):
	if actor.global_position.distance_to(blackboard.get_value("player_pos")) > 20:
		return SUCCESS
	
	return FAILURE
	
