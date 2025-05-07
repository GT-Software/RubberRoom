extends ActionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	if actor.is_in_range:
		actor.rotate_node = null
	else:
		actor.rotate_self = true
		actor.rotate_target = blackboard.get_value("player_pos")
		actor.rotate_node = actor.target
		
	return SUCCESS

func interrupt(actor: Node, blackboard: Blackboard) -> void:
	var enemy = actor as Enemy
	enemy.rotate_self = false # Stop rotation
	print("Face enemy interrupted")
