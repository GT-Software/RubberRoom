extends ActionLeaf


func tick(actor, blackboard: Blackboard):
	if !actor.nav_agent:
		print("No agent found.")
		return FAILURE
		
	if actor.nav_agent.is_target_reached() and blackboard.get_value("moving for cover") == true:
		print("Actor found cover.")
		blackboard.set_value("moving for cover", false)
		blackboard.set_value("at cover", true)
		
		return FAILURE
	else:
		print("Looking for cover.")
		
		# Get the cover nodes
		var room_obstacles = get_tree().get_nodes_in_group("cover")
		# Find the closest spot for cover
		var closest = room_obstacles[shortest_distance(room_obstacles, actor.global_position)]
	
		actor.update_target_location(closest.global_position)
		actor.update_nav_agent()
		blackboard.set_value("moving for cover", true)
		print("moving for cover")
		return RUNNING

## Gets the index of the obstacle closest to the actor
func shortest_distance(list : Variant, position : Vector3) -> int:
	var current = [0, position.distance_to(list[0].global_position)]
	for obs in list:
		var distance = position.distance_to(obs.global_position)
		if distance < current[1]:
			current[0] = list.find(obs)
			current[1] = distance
			print("Distance to ", obs.name, ": ", current[1], " | Index: ", current[0])
			
		
	return current[0] 
