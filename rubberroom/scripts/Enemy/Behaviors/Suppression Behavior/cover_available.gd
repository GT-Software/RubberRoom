extends ConditionLeaf

@export var max_cover_distance: float = 15.0
@export var cover_check_height: float = 1.5  # Height to check cover effectiveness

func tick(actor: Node, blackboard: Blackboard) -> int:
	var actor_position = actor.global_position
	var player_position = blackboard.get_value("player_position", Vector3.ZERO)
	var nearby_cover_points = blackboard.get_value("nearby_cover_points", [])
	
	# Find valid cover points
	var valid_cover = []
	
	for cover_point in nearby_cover_points:
		var distance = actor_position.distance_to(cover_point)
		
		# Skip if too far
		if distance > max_cover_distance:
			continue
		
		# Check if cover actually blocks line of sight to player
		if _is_valid_cover(actor, cover_point, player_position):
			valid_cover.append({
				"position": cover_point, 
				"distance": distance
			})
	
	if valid_cover.size() > 0:
		# Sort by distance and store closest cover
		valid_cover.sort_custom(func(a, b): return a.distance < b.distance)
		blackboard.set_value("selected_cover_point", valid_cover[0].position)
		return SUCCESS
	else:
		return FAILURE


func _is_valid_cover(actor: Node, cover_position: Vector3, player_position: Vector3) -> bool:
	var world = actor.get_world_3d().direct_space_state
	
	# Check if cover blocks line of sight from cover point to player
	var cover_check_pos = cover_position + Vector3.UP * cover_check_height
	var query = PhysicsRayQueryParameters3D.create(cover_check_pos, player_position)
	query.exclude = [actor]	# Don't hit yourself
	
	var result = world.intersect_ray(query)
	# If ray hits something before reaching player, it's good cover
	return result != null
