extends ActionLeaf

@export var grapple_range: float = 1.5
@export var grapple_duration: float = 1.2

var grapple_timer: float = 0.0
var is_grappling: bool = false

func tick(actor: Node, blackboard: Blackboard) -> int:
	var player_position = blackboard.get_value("player_position", Vector3.ZERO)
	var delta = get_process_delta_time()
	
	if not is_grappling:
		var distance = actor.global_position.distance_to(player_position)
		if distance <= grapple_range:
			is_grappling = true
			grapple_timer = grapple_duration
			_execute_grapple(actor, player_position)
			return RUNNING
		else:
			return FAILURE
	
	return SUCCESS

# Enter Grapple Logic
func _execute_grapple(actor: Node, target_position: Vector3):
	pass
