extends ActionLeaf


func tick(actor, blackboard: Blackboard):
	# Ryan: Put your animation calls here. The idea is that it would pick 
	# a random idle animation when we make new animations.
	#var ap = actor.anim_tree.get_node(actor.anim_tree.anim_player)
	# Initial idle animation
	#if ap.current_animation == "":
		#ap.play("Idle(1)0")
	#
	#if ap.is_playing():
		#ap.animation_set_next("Idle(1)0", "Idle(2)0")
	actor.update_nav_agent()
	actor.is_idle = true
	actor.is_walking = false
	actor.is_running = false
	actor.update_animation_state()
	
	return SUCCESS
