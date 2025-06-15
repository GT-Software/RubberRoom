extends ConditionLeaf

@export var melee_range: float = 2.5

func tick(actor: Node, blackboard: Blackboard) -> int:
	var player_distance = blackboard.get_value("player_distance", 999.0)
	
	if player_distance <= melee_range:
		return SUCCESS
	else:
		return FAILURE
