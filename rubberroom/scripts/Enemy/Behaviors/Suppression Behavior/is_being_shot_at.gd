extends ConditionLeaf
	
@export var suppression_timeout: float = 3.0	# How long to stay suppressed after last shot
@export var projectile_detection_radius: float = 5.0	# Range to detect nearby bullets

func tick(actor: Node, blackboard: Blackboard) -> int:
	var incoming_projectiles = blackboard.get_value("incoming_projectiles", [])
	var suppression_timer = blackboard.get_value("suppression_timer", 0.0)
	
	# Update suppression timer
	if incoming_projectiles.size() > 0:
		# Reset timer if projectiles are incoming
		blackboard.set_value("suppression_timer", suppression_timeout)
		return SUCCESS
	else:
		# Decrease timer
		suppression_timer -= get_process_delta_time()
		blackboard.set_value("suppression_timer", suppression_timer)
		
		# Still suppressed if timer hasn't expired
		if suppression_timer > 0:
			return SUCCESS
		else:
			return FAILURE
