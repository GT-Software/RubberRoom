extends ActionLeaf

@export var heavy_attack_damage: float = 50.0
@export var heavy_attack_range: float = 3.0
@export var windup_time: float = 1.0
@export var recovery_time: float = 1.5

var attack_state: String = "idle"
var state_timer: float = 0.0

func tick(actor: Node, blackboard: Blackboard) -> int:
	var current_weapon = blackboard.get_value("current_weapon", null)
	var player_position = blackboard.get_value("player_position", Vector3.ZERO)
	var delta = get_process_delta_time()

	# I don't think we need any of this, as its all done in the Animation tree?
	match attack_state:
		"idle":
			attack_state = "windup"
			state_timer = windup_time
			# Play windup animation
			if actor.has_method("play_animation"):
				actor.play_animation("heavy_attack_windup")
			return RUNNING
		
		"windup":
			state_timer -= delta
			if state_timer <= 0:
				attack_state = "execute"
				_execute_heavy_attack(actor, current_weapon, player_position, blackboard)
				state_timer = recovery_time
			return RUNNING
		
		"execute":
			state_timer -= delta
			if state_timer <= 0:
				attack_state = "idle"
				return SUCCESS
			return RUNNING
	
	return FAILURE


func _execute_heavy_attack(actor: Node, weapon, target_position: Vector3, blackboard: Blackboard):
	# Play attack animation here
	if actor.has_method("play_animation"):
		actor.play_animation("heavy_attack_execute")
	
	# Check if attack hits
	var distance = actor.global_position.distance_to(target_position)
	if distance <= heavy_attack_range:
		# Deal damage
		# I think we really need to reevaluate how we handle attacks and getting attacked
		if weapon and actor.has_method("take_damage"):
			actor.take_damage(blackboard.get_value("attack", null))
			
