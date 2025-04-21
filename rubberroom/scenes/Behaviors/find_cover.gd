extends ActionLeaf


func tick(actor, blackboard: Blackboard):
	if actor.nav_agent:
		print("No agent found")
	
	var room_obstacles = get_tree().get_nodes_in_group("cover")
	
	var closest = room_obstacles[shortest_distance(room_obstacles, actor.global_position)]
	
	actor.update_target_location(closest.global_position)
	actor.update_nav_agent()
	
	return SUCCESS

## Gets the index of the obstacle closest to the actor
func shortest_distance(list : Variant, position : Vector3) -> int:
	var index = 0
	var current = [0, position.distance_to(list[0])]
	for obs in list:
		var distance = position.distance_to(obs.global_position)
		if distance < current:
			current[0] = index
			current[1] = distance
			print("Distance to ", obs.name, ": ", current[1], " | Index: ", current[0])
			
		index += 1
		
	return current[1] 
