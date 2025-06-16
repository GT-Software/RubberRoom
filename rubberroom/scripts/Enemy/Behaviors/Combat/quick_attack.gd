extends ActionLeaf

@export var quick_attack_damage: float = 25.0
@export var quick_attack_range: float = 2.0
@export var attack_speed: float = 0.5

var attack_timer: float = 0.0
var is_attacking: bool = false


func tick(actor: Node, blackboard: Blackboard) -> int:
	var current_weapon = blackboard.get_value("current_weapon", null)
	var player_position = blackboard.get_value("player_position", Vector3.ZERO)
	var delta = get_process_delta_time()
	
	if not is_attacking:
		is_attacking = true
		attack_timer = attack_speed
		
		# Execute quick attack immediately
		_execute_quick_attack(actor, current_weapon, player_position, blackboard)
		
		if actor.has_method("play_animation"):
			actor.play_animation("quick_attack")
		
		return RUNNING
	
	attack_timer -= delta
	if attack_timer <= 0:
		is_attacking = false
		return SUCCESS
	
	return RUNNING


func _execute_quick_attack(actor: Node, weapon, target_position: Vector3, blackboard: Blackboard):
	var distance = actor.global_position.distance_to(target_position)
	if distance <= quick_attack_range:
		# I think we really need to reevaluate how we handle attacks and getting attacked
		if weapon and actor.has_method("take_damage"):
			actor.take_damage(blackboard.get_value("attack", null))
