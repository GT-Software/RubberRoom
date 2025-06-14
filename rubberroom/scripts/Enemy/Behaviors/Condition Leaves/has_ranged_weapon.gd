extends ConditionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	var current_weapon = blackboard.get_value("current_weapon", null)
	
	# Ryan: Must separate Ammo systems so gun has ammo and player/enemy has ammo
	if current_weapon and current_weapon.Classification == Item.Classification.RANGED:
		return SUCCESS
	else:
		return FAILURE
