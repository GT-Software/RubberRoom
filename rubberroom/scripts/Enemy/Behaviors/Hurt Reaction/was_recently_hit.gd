extends ConditionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	var is_hurt = blackboard.get_value("is_hurt", false)
	var hurt_timer = blackboard.get_value("hurt_timer", 0.0)
	
	# If hurt and timer hasn't expired
	if is_hurt and hurt_timer > 0.0:
		return SUCCESS
	else:
		# Clear hurt state if timer expired
		if is_hurt and hurt_timer <= 0.0:
			blackboard.set_value("is_hurt", false)
		return FAILURE
