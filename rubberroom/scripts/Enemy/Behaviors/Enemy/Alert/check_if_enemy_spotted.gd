extends ConditionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	if blackboard.blackboard['attacking']:
		return FAILURE
		
	actor.nav_agent.set_velocity(Vector3.ZERO)
	
	var hit = actor.raycast.get_collider()
	
	if hit:
		if hit.is_in_group('player'):
			return FAILURE
		elif !hit.is_in_group('player'):
			return SUCCESS
			
	return SUCCESS
