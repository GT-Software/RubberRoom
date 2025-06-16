extends ActionLeaf

@export var combo_hits: int = 3
@export var hit_damage: float = 20.0
@export var hit_interval: float = 0.4
@export var combo_range: float = 2.5

var combo_state: int = 0
var hit_timer: float = 0.0

func tick(actor: Node, blackboard: Blackboard) -> int:
	var current_weapon = blackboard.get_value("current_weapon", null)
	var player_position = blackboard.get_value("player_position", Vector3.ZERO)
	var delta = get_process_delta_time()
	
	if combo_state == 0:
		combo_state = 1
		hit_timer = hit_interval
		_execute_combo_hit(actor, current_weapon, player_position, 1, blackboard)
		return RUNNING
	
	hit_timer -= delta
	if hit_timer <= 0:
		combo_state += 1
		if combo_state <= combo_hits:
			hit_timer = hit_interval
			_execute_combo_hit(actor, current_weapon, player_position, combo_state, blackboard)
			return RUNNING
		else:
			combo_state = 0
			return SUCCESS
	
	return RUNNING


func _execute_combo_hit(actor: Node, weapon, target_position: Vector3, hit_number: int, blackboard: Blackboard):
	if actor.has_method("play_animation"):
		actor.play_animation("combo_attack_" + str(hit_number))
	
	var distance = actor.global_position.distance_to(target_position)
	if distance <= combo_range:
		if weapon and actor.has_method("take_damage"):
			actor.take_damage(blackboard.get_value("attack", null))
