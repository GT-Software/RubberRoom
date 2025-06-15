extends ConditionLeaf

@export var min_ranged_range: float = 3.0
@export var max_ranged_range: float = 15.0

func tick(actor: Node, blackboard: Blackboard) -> int:
	var player_distance = blackboard.get_value("player_distance", 999.0)
	
	# Check if the player is within the minimum and maxmimum range for a ranged weapon
	if player_distance >= min_ranged_range and player_distance <= max_ranged_range:
		return SUCCESS
	else:
		return FAILURE
