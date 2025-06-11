extends ConditionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	var enemy_pos = actor.global_position
	var player_pos = blackboard.get_value("player_pos")
	
	if enemy_pos.distance_to(player_pos) <= 20:
		return SUCCESS
	else:
		return FAILURE 
