extends ConditionLeaf


func tick(actor, blackboard: Blackboard):
	if actor.current_weapon.ammo_type == Item.AmmoType.RIFLE:
		return SUCCESS
	return FAILURE
