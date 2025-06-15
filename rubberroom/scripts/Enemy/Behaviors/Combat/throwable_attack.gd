extends ActionLeaf

@export var throw_force: float = 15.0
@export var throw_arc: float = 0.3  # How high to arc the throw


func tick(actor: Node, blackboard: Blackboard) -> int:
	var current_weapon = blackboard.get_value("current_weapon", null)
	var player_position = blackboard.get_value("player_position", Vector3.ZERO)
	
	if not current_weapon or not current_weapon.has_method("is_throwable") or not current_weapon.is_throwable():
		return FAILURE
	
	# Calculate throw trajectory
	var throw_velocity = _calculate_throw_velocity(actor.global_position, player_position)
	
	if throw_velocity != Vector3.ZERO:
		current_weapon.throw(throw_velocity)
		return SUCCESS
	else:
		return FAILURE


func _calculate_throw_velocity(start_pos: Vector3, target_pos: Vector3) -> Vector3:
	var distance = start_pos.distance_to(target_pos)
	var direction = (target_pos - start_pos).normalized()
	
	# Simple arc calculation
	var horizontal_velocity = direction * throw_force
	var vertical_velocity = Vector3.UP * (throw_force * throw_arc)
	
	return horizontal_velocity + vertical_velocity
