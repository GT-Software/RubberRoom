extends ConditionLeaf

# If the player IS NOT detected, then return success and continue on to actions
func tick(actor, blackboard):
	if actor.player_in_detection_area:
		return FAILURE
	return SUCCESS
