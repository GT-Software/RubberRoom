extends ActionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	if actor.nav_agent.is_target_reached():
		actor.is_running = false
		actor.update_target_location(actor.global_position)
		return FAILURE
	else:
		var marker : Marker3D = Marker3D.new()
		get_tree().root.get_node("World").add_child(marker)
		marker.global_position = blackboard.get_value("safe_position")
		
		actor.is_running = true
		
		actor.rotate_self = true
		actor.rotate_target = marker.global_position
		actor.rotate_node = marker
		return RUNNING
