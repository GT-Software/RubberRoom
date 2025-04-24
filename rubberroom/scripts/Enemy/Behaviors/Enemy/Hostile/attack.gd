extends ActionLeaf

func tick(actor, blackboard):
	if actor.get_lightattack_animation() != blackboard.get_value("attack animation") and blackboard.get_value("attacking") == true:
		blackboard.set_value("attacking", false)
		blackboard.set_value("attack animation", false)
		return FAILURE
	
	if blackboard.get_value("attacking") == true and blackboard.get_value("attack animation") == actor.get_lightattack_animation():
		#print("Is attacking: ", actor.get_current_animation())
		#actor.update_nav_agent(0)
		return RUNNING
	else:
		blackboard.set_value("attacking", true)
		blackboard.set_value("attack animation", actor.attack())
		return SUCCESS
		
