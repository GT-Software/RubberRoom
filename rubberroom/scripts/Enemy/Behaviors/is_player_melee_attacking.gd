extends ConditionLeaf

func tick(actor, blackboard: Blackboard):
	var player = blackboard.get_value("player") as Node
	#print(player.get_current_attack_type())
	if player.get_current_attack_type().contains("melee"):
		return SUCCESS
	return FAILURE
