extends ConditionLeaf


func tick(actor, blackboard: Blackboard):
	if actor.ammo_manager.get_ammo_type() == Item.AmmoType.PISTOL:
		return SUCCESS
	return FAILURE
