extends ActionLeaf

func tick(actor, _blackboard):
	actor.attack()
	#actor.combo_index = 1
	#actor.combo_timer = 1.35
	#actor.in_light_combo = true
	return SUCCESS 
