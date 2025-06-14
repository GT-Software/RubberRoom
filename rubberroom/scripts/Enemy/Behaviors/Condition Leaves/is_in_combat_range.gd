extends ConditionLeaf

@export var max_combat_range: float = 20.0

func tick(actor: Node, blackboard: Blackboard) -> int:
	var player_distance = blackboard.get_value("player_distance", 999.0)
	
	if player_distance <= max_combat_range:
		return SUCCESS
	else:
		return FAILURE
