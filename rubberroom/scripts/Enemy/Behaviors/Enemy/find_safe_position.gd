extends ActionLeaf

@onready var nav_region = get_tree().get_nodes_in_group("nav region")[0]

func tick(actor: Node, blackboard: Blackboard):
	var safe_pos = find_safe_pos(actor, blackboard)
	
	if safe_pos != Vector3.ZERO:
		print("safe_pos is zero")
		blackboard.set_value("safe_position", safe_pos)
		return SUCCESS
	
	print(actor.name, "; BasicBeehaveTree-Retreat-FindSafePosition; Safe Position Not Found!")
	return FAILURE
	

func find_safe_pos(actor: Node, blackboard: Blackboard) -> Vector3:
	var current_pos = actor.global_position
	var player_pos = blackboard.get_value("player_pos")
	var max_attempts = 10
	var min_distance = 10.0 # Minimum distance from player
	
	for i in range(max_attempts):
		# Generate a random point within a sphere
		var random_offset = Vector3(
			randf_range(-min_distance, min_distance),
			0,
			randf_range(-min_distance, min_distance)
		).normalized() * min_distance
		var target_pos = current_pos + random_offset
		
		# Get the closest navigable point
		var closest_pos = NavigationServer3D.map_get_closest_point(nav_region.get_navigation_map(), target_pos)
		print(actor.name, "; BasicBeehaveTree-Retreat-FindSafePosition; Closest Navigable Point: ", closest_pos, " | Distance from Player: ", closest_pos.distance_to(player_pos))
		# Check if the point is far enough from the player
		if closest_pos.distance_to(player_pos) >= min_distance:
			return closest_pos
	
	return Vector3.ZERO  # Return invalid position if no safe position found
