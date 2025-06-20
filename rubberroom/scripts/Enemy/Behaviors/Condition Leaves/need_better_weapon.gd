extends ConditionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	var current_weapon = blackboard.get_value("current_weapon", null)
	var nearby_weapons = blackboard.get_value("nearby_weapons", [])
	var ammo_manager = actor.ammo_manager
	
	if nearby_weapons.size() == 0:
		return FAILURE
	
	# If no current weapon, any weapon is better
	if not current_weapon:
		blackboard.set_value("target_pickup_weapon", nearby_weapons[0])
		return SUCCESS
	
	# Compare weapon effectiveness
	var best_nearby_weapon = null
	var best_score = _get_weapon_score(current_weapon, ammo_manager)
	
	for weapon_data in nearby_weapons:
		var weapon = weapon_data.weapon
		var score = _get_weapon_score(weapon, ammo_manager)
		
		if score > best_score:
			best_score = score
			best_nearby_weapon = weapon_data
	
	if best_nearby_weapon:
		blackboard.set_value("target_pickup_weapon", best_nearby_weapon)
		return SUCCESS
	else:
		return FAILURE


func _get_weapon_score(weapon, ammo_manager) -> float:
	if not weapon:
		return 0.0
	
	var score = 0.0
	
	# Base weapon type scores
	match weapon.classification:
		Item.Classification.BLUNT:
			score += 30.0
		Item.Classification.BLADED:
			score += 60.0
		Item.Classification.RANGED:
			score += 90.0
		Item.Classification.SPECIAL:
			score += 100.0
	
	# Damage factor
	score += weapon.damage * 0.5
	
	# Ammo Factor (For ranged weapons)
	if weapon.classification == Item.Classification.RANGED and ammo_manager.has_method("get_ammo") and ammo_manager.has_method("get_max_ammo"):
		var ammo_ratio = float(weapon.get_ammo(ammo_manager.current_weapon_type)) / float(weapon.get_max_ammo())
		score += ammo_ratio * 20.0	# Bonus for weapons with ammo
		
		# Range factor
		if weapon.has_method("get_range"):
			score += weapon.get_range() * 0.1
		
		# Durability factor(?)
		if weapon.has_method("get_durability"):
			score += weapon.get_durability() * 0.2
		
	return score
