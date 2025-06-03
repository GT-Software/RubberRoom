extends ActionLeaf


func tick(actor, blackboard: Blackboard):
	# Fire Weapon
	var weapon = actor.current_weapon
	# Spawn projectile(s)
	var projectile_count = weapon.projectile_count
	for i in range(projectile_count):
		# Create projectile instance
		var projectile = weapon.projectile_scene.instantiate()
		actor.projectile_container.add_child(projectile)
		
	# Set projectile position to muzzle or fallback to weapon attachment
		if actor.muzzle_position:
			projectile.global_position = actor.muzzle_position.global_position
		else:
			print("Warning: MuzzlePosition is null, using weapon attachment position!")
			projectile.global_position = actor.weapon_attachment.global_position
		
		# Calculate projectile direction with spread
		var direction = actor.base_direction
		
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
			actor.direction,
			actor.global_position,
			actor
		)
		
		# Optional: Spawn muzzle flash effect
		if weapon.muzzle_flash_scene:
			var muzzle_flash = weapon.muzzle_flash_scene.instantiate()
			if actor.muzzle_position:
				actor.muzzle_position.add_child(muzzle_flash)
			else:
				actor.weapon_attachment.add_child(muzzle_flash)
		
	print("Fired Rifle")
	return FAILURE
