extends ActionLeaf


@export var threat_scan_range: float = 15.0
@export var scan_interval: float = 0.5

var scan_timer: float = 0.0

func tick(actor: Node, blackboard: Blackboard) -> int:
	var delta = get_process_delta_time()
	scan_timer -= delta
	
	if scan_timer <= 0:
		scan_timer = scan_interval
		_scan_for_threats(actor, blackboard)
	
	return SUCCESS


func _scan_for_threats(actor: Node, blackboard: Blackboard):
	# Scan for incoming projectiles
	var incoming_projectiles = []
	var bodies = actor.get_world_3d().direct_space_state
	
	# This is a simplified threat detection - expand based on our game's needs
	var player_position = blackboard.get_value("player_position", Vector3.ZERO)
	var distance_to_player = blackboard.get_value("player_distance", 999.0)
	
	# Update threat level based on distance and player behavior
	var threat_level = 1.0 - (distance_to_player / threat_scan_range)
	blackboard.set_value("current_threat_level", threat_level)
