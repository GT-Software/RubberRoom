extends ConditionLeaf

# If the player IS NOT detected, then return success and continue on to actions
func tick(actor, _blackboard):
	if actor.target:
		return FAILURE
	return SUCCESS
