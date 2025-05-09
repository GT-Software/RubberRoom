extends ConditionLeaf

func tick(actor, blackboard: Blackboard):
	var player = blackboard.get_value("player") as Node
	#print(player.get_current_attack_type())
	if player.get_current_attack_type().contains("melee") and blackboard.get_value("player attack") != null:
		return SUCCESS
	return FAILURE
