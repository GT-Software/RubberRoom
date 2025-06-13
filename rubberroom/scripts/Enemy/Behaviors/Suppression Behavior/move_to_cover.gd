extends ActionLeaf

@export var move_speed: float = 6.0
@export var arrival_threshold: float = 0.5

var target_position: Vector3

func tick(actor: Node, blackboard: Blackboard) -> int:
	var cover_point = blackboard.get_value("selected_cover_point", Vector3.ZERO)
	var navigation_agent = actor.nav_agent
	
	if cover_point == Vector3.ZERO:
		return FAILURE
	
	# Set navigation target
	if navigation_agent.target_position != cover_point:
		navigation_agent.target_position = cover_point
		target_position = cover_point
	
	# Move towards cover
	if navigation_agent.is_navigation_finished():
		return SUCCESS
	
	var next_position = navigation_agent.get_next_path_position()
	var direction = (next_position - actor.global_position).normalized()
	
	if actor.has_method("set_velocity"):
		actor.set_velocity(direction * move_speed)
		actor.move_and_slide()
	elif actor.has_method("move_toward"):
		actor.move_toward(next_position, move_speed * get_process_delta_time())
	
	# Check if we've arrived
	var distance_to_target = actor.global_position.distance_to(target_position)
	if distance_to_target < arrival_threshold:
		return SUCCESS
	
	return RUNNING
