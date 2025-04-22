extends ActionLeaf

func tick(actor, blackboard):
	if actor.get_current_animation() != blackboard.get_value("attack animation") and blackboard.get_value("attacking") == true:
		blackboard.set_value("attacking", false)
		blackboard.set_value("attack animation", "")
		return FAILURE
	
	if blackboard.get_value("attacking") == true and blackboard.get_value("attack animation") == actor.get_current_animation():
		print(actor.get_current_animation())
		return RUNNING
	else:
		blackboard.set_value("attacking", true)
		blackboard.set_value("attack animation", actor.attack())
		return SUCCESS
		
