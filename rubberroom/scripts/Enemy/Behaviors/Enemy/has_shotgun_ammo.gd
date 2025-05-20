extends ConditionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	if actor.ammo_manager.get_ammo_type() == AmmoManager.AmmoType.SHOTGUN:
		return SUCCESS
	return FAILURE
