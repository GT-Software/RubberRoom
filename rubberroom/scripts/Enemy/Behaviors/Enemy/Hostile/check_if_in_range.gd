extends ConditionLeaf


func tick(actor, blackboard):
	if actor.player_in_detection_area:
		return SUCCESS
	return FAILURE
