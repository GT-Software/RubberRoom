extends ConditionLeaf


func tick(actor, blackboard: Blackboard):
	if actor.ammo_manager.get_ammo_type() == AmmoManager.AmmoType.RIFLE:
		return SUCCESS
	return FAILURE
