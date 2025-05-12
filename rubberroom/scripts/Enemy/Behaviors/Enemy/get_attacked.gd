extends ActionLeaf


func tick(actor, blackboard: Blackboard):
	var attack = blackboard.get_value("player attack")
	
	# If the attack is null run until the player connects with the enemy
	if attack == null:
		return FAILURE
	# If the player's fist connects with the enemy (is attacked becomes true), it'll actually consider
	# that the enemy must take damage and go through the GotHit animation.
	elif blackboard.get_value("is attacked") == true:
		actor.take_damage(attack)
		actor.anim_tree.set("parameters/GotHit/request" , AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		print("Received player_attacking signal with: ", attack)
		actor.enemy_health_bar._on_health_changed(actor.health_component.health)
		actor.apply_hitstun(actor.hitstun_duration)
		actor.punch_sound.play()
		print("Current Enemy Health: ", actor.health_component.get_health())
		blackboard.set_value("is attacked", false)
		return SUCCESS
		
