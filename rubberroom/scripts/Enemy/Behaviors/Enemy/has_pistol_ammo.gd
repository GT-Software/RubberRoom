extends ConditionLeaf


func tick(actor, blackboard: Blackboard):
	if actor.current_weapon.ammo_type == Item.AmmoType.PISTOL:
		return SUCCESS
	return FAILURE
