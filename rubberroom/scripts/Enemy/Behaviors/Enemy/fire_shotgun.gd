extends ActionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	var weapon = actor.current_weapon
	var weapon_model = actor.current_weapon_model
	var muzzle_position = weapon_model.get_node("MuzzlePosition")
	
	# Query a ray from the weapaon to the player
	var ray_query = PhysicsRayQueryParameters3D.create(muzzle_position.global_position, blackboard.get_value("player_pos"))
	var result = actor.get_world_3d().direct_space_state.intersect_ray(ray_query)
	
	# Grab where to aim
	var aim_point
	if result:
		aim_point = result.position
	else:
		return SUCCESS
	
	
	# Calculate direction from muzzle to aim point
	var base_direction
	if muzzle_position:
		base_direction = (aim_point - muzzle_position.global_position).normalized()
	else:
		base_direction = (aim_point - actor.weapon_attachment.global_position).normalized()
	
	# Spawn projectile(s)
	var projectile_count = weapon.projectile_count
	for i in range(projectile_count):
		# Create projectile instance
		var projectile = weapon.projectile_scene.instantiate()
		projectile.set_collision_mask_value(3, false)
		actor.projectile_container.add_child(projectile)
		
	# Set projectile position to muzzle or fallback to weapon attachment
		if muzzle_position:
			projectile.global_position = muzzle_position.global_position
		else:
			print("Warning: MuzzlePosition is null, using weapon attachment position!")
			projectile.global_position = actor.weapon_attachment.global_position
		
		# Calculate projectile direction with spread
		var direction = base_direction
		
		# Add spread if applicable
		if weapon.spread > 0.0 or i > 0:
			var rand_spread_x = randf_range(-weapon.spread, weapon.spread)
			var rand_spread_y = randf_range(-weapon.spread, weapon.spread)
			var rot_basis = Basis(Vector3.UP, deg_to_rad(rand_spread_y)) * Basis(Vector3.RIGHT, deg_to_rad(rand_spread_x))
			direction = rot_basis * direction
		
		# Set up the projectile
		projectile.setup(
			weapon.damage,
			weapon.projectile_speed,
			blackboard.get_value("player_pos"),
			actor.global_position,
			actor
		)
		
		if actor.firing_sound:
			actor.firing_sound.stream = weapon.sound_fire
			actor.firing_sound.play()
		
		# Optional: Spawn muzzle flash effect
		if weapon.muzzle_flash_scene:
			var muzzle_flash = weapon.muzzle_flash_scene.instantiate()
			if actor.muzzle_position:
				weapon.muzzle_position.add_child(muzzle_flash)
			else:
				actor.weapon_attachment.add_child(muzzle_flash)
		
	print("Fired Shotgun")
	return FAILURE
