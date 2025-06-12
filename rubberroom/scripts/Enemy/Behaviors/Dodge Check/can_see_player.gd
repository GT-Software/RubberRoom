extends ConditionLeaf

@export var max_sight_distance: float = 20.0
@export var sight_angle_degrees: float = 120.0

func tick(actor: Node, blackboard: Blackboard) -> int:
	var player_position = blackboard.get_value("player_position", Vector3.ZERO)
	var actor_position = actor.global_position
	
	# Check distance
	var distance = actor_position.distance_to(player_position)
	if distance > max_sight_distance:
		return FAILURE
	
	# Line of sight check
	var space_state = actor.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		actor_position + Vector3(0, 1.5, 0), # Eye Level (can be modified)
		player_position + Vector3(0, 1, 0) # Player center (can be modified)
	)
	query.exclude = [actor]
	
	var result = space_state.intersect_ray(query)
	
	# Check if we hit the player or nothing (clear line of sight)
	if result.is_empty():
		blackboard.set_value("can_see_player", true)
		return SUCCESS
		
	var hit_body = result.get("collider")
	if hit_body and hit_body.is_in_group("player"):
		blackboard.set_value("can_see_player", true)
		return SUCCESS
	
	blackboard.set_value("can_see_player", false)
	return FAILURE
