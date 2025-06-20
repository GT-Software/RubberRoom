extends ConditionLeaf

@export var detection_radius: float = 8.0
@export var scan_interval: float = 1.0	# How often to scan for weapons

var scan_timer: float = 0.0

func tick(actor: Node, blackboard: Blackboard) -> int:
	var delta = get_process_delta_time()
	scan_timer -= delta
	
	if scan_timer <= 0:
		scan_timer = scan_interval
		_scan_for_weapons(actor, blackboard)
	
	var nearby_weapons = blackboard.get_value("nearby_weapons", [])
	
	if nearby_weapons.size() > 0:
		return SUCCESS
	else:
		return FAILURE


func _scan_for_weapons(actor: Node, blackboard: Blackboard):
	var nearby_weapons = []
	var actor_position = actor.global_position
	
	# Get all weapons in the scene
	var weapons = get_tree().get_nodes_in_group("weapons")
	
	for weapon in weapons:
		if not weapon.is_pickupable:
			continue
		
		var distance = actor_position.distance_to(weapon.global_position)
		if distance <= detection_radius:
			nearby_weapons.append({
				"weapon": weapon,
				"distance": distance,
				"position": weapon.global_position
			})
		
		# Sort by distance
		nearby_weapons.sort_custom(func(a, b): return a.distance < b.distance)
		
		blackboard.set_value("nearby_weapons", nearby_weapons)
		
