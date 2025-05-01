extends ActionLeaf


func tick(actor, blackboard: Blackboard):
	var attack = blackboard.get_value("player_attack")
	
	actor.take_damage(attack)
	actor.anim_tree.set("parameters/GotHit/request" , AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	print("Received player_attacking signal with: ", attack)
	actor.enemy_health_bar._on_health_changed(actor.health_component.health)
	actor.apply_hitstun(actor.hitstun_duration)
	actor.punch_sound.play()
	print("Current Enemy Health: ", actor.health_component.get_health())
	
	return SUCCESS
