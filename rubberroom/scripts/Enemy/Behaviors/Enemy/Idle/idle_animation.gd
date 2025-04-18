extends ActionLeaf


func tick(actor, blackboard: Blackboard):
	# Ryan: Put your animation calls here. The idea is that it would pick 
	# a random idle animation when we make new animations.
	
	# Initial idle animation
	if actor.anim_tree.anim_player.current_animation == "":
		actor.anim_tree.anim_player.play("Idle(1)0")
	
	if actor.anim_tree.anim_player.is_playing():
		actor.anim_tree.anim_player.animation_set_next("Idle(1)0", "Idle(2)0")
	
	return SUCCESS
