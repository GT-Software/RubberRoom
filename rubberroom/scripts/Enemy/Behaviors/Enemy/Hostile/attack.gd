extends ActionLeaf

func tick(actor, blackboard):
	if actor.get_lightattack_animation() != blackboard.get_value("attack animation") and blackboard.get_value("attacking") == true:
		blackboard.set_value("attacking", false)
		blackboard.set_value("attack animation", false)
		return FAILURE
	
	if blackboard.get_value("attacking") == true and actor.get_lightattack_animation() == true:
		#print("Is attacking: ", actor.get_current_animation())
		#actor.update_nav_agent(0)
		return RUNNING
	else:
		blackboard.set_value("attacking", true)
		blackboard.set_value("attack animation", actor.attack())
		return SUCCESS
		

func interrupt(actor: Node, blackboard: Blackboard) -> void:
	var enemy = actor as Enemy
	if blackboard.get_value("attacking") == true:
		# Stop the attack animation
		enemy.anim_tree.set("parameters/LightAttack/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
		blackboard.set_value("attacking", false)
		blackboard.set_value("attack animation", false)
		print("Attack interrupted!")
