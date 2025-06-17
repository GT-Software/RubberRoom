extends ActionLeaf

@export var punch_range: float = 1.8
@export var combo_length: int = 2

# Tracks which stage of the punch combo the action is currently in
# i.e. 0 = Idle/Ready, 1 = First Punch, 2 = Second Punch
var punch_state: int = 0
var punch_timer: float = 0.0

func tick(actor: Node, blackboard: Blackboard) -> int:
	var player_position = blackboard.get_value("player_position", Vector3.ZERO)
	var delta = get_process_delta_time()
	
	if punch_state == 0:
		punch_state = 1
		punch_timer = 0.3
		_execute_punch(actor, player_position, 1)
		return RUNNING
	
	return SUCCESS

# Handle Punch here
func _execute_punch(actor: Node, target_position: Vector3, punch_number: int):
	pass
