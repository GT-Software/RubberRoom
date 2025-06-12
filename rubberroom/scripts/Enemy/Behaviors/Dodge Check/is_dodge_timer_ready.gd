extends ConditionLeaf

@export var dodge_cooldown_duration: float = 2.0

func tick(actor: Node, blackboard: Blackboard) -> int:
	var dodge_cooldown = blackboard.get_value("dodge_cooldown", 0.0)
	
	# Update cooldown timer
	var delta = actor.get_process_delta_time()
	dodge_cooldown -= delta
	if dodge_cooldown < 0:
		dodge_cooldown = 0
	
	blackboard.set_value("dodge_cooldown", dodge_cooldown)
	
	# Check if dodge is read
	if dodge_cooldown <= 0:
		return SUCCESS
	else:
		return FAILURE
