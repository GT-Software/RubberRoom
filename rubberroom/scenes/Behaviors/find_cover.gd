extends ActionLeaf


func tick(actor, blackboard: Blackboard):
	if !actor.nav_agent:
		print("No agent found.")
		return FAILURE
	
	if blackboard.get_value("at cover") == true:
		return FAILURE
		
	if actor.nav_agent.is_target_reached() and blackboard.get_value("moving for cover") == true and actor.nav_agent.target_position == blackboard.get_value("cover spot"):
		print("Actor found cover.")
		blackboard.set_value("moving for cover", false)
		blackboard.set_value("at cover", true)
		
		# Update animation states (Expecting a cover animation)
		actor.is_idle = true
		actor.is_walking = false
		actor.is_running = false
		
		return FAILURE
	elif blackboard.get_value("moving for cover") == false:
		print("Looking for cover.")
		
		# Get the cover nodes
		var room_obstacles = get_tree().get_nodes_in_group("cover")
		# Find the closest marker for cover
		var closest_cover = room_obstacles[shortest_distance(room_obstacles, actor.global_position)]
		var cover_markers = get_cover_markers(closest_cover)
		var closest_spot = farthest_distance(cover_markers, actor.player)
		
		blackboard.set_value("cover spot", closest_spot)
		# Update the nav_agent with the closest_spot as the target
		
		actor.rotate_self = true
		actor.rotate_target = closest_spot
		actor.rotate_node = closest_cover
		
		actor.update_target_location(closest_spot)
		actor.update_nav_agent(actor.SPEED)
		blackboard.set_value("moving for cover", true)
		print("moving for cover at ", closest_spot)
		
		# Update animation states
		actor.is_idle = false
		actor.is_walking = false
		actor.is_running = true
		
		return SUCCESS
	else:
		actor.update_target_location(blackboard.get_value("cover spot"))
		actor.update_nav_agent(actor.SPEED)
		return RUNNING

## Gets the index of the obstacle closest to the actor
func shortest_distance(list : Array, position : Vector3) -> int:
	var current = [0, position.distance_to(list[0].global_position)]
	for obs in list:
		var distance = position.distance_to(obs.global_position)
		if distance < current[1]:
			current[0] = list.find(obs)
			current[1] = distance
			print("Distance to ", obs.name, ": ", current[1], " | Index: ", current[0])
			
		
	return current[0] 

func farthest_distance(list : Array, player : CharacterBody3D) -> Vector3:
	var current = [Vector3(0, 0, 0), player.global_position.distance_to(list[0].global_position)]
	for pos in list:
		var distance = player.global_position.distance_to(pos.global_position)
		if distance > current[1]:
			current[0] = pos.global_position
			current[1] = distance
			print("Distance to ", pos.name, ": ", current[1], " | Vector: ", current[0])
			
		
	return current[0] 

func get_cover_markers(parent_node: Node) -> Array:
	var cover_markers: Array = []
	for child in parent_node.get_children():
		if child.is_in_group("cover marker"):
			cover_markers.append(child)
	return cover_markers
