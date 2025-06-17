extends ActionLeaf

@export var kick_duration: float = 0.8

var kick_timer: float = 0.0
var is_kicking: bool = false

func tick(actor: Node, blackboard: Blackboard) -> int:
	var player_position = blackboard.get_value("player_position", Vector3.ZERO)
	var delta = get_process_delta_time()
	
	if not is_kicking:
		is_kicking = true
		kick_timer = kick_duration
		_execute_kick(actor, player_position)
		return RUNNING
	
	
	return SUCCESS

# Enter Kick Logic Here
func _execute_kick(actor: Node, target_position: Vector3):
	pass
