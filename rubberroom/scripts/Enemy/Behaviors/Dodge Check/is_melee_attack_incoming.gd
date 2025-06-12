extends ConditionLeaf

@export var detection_range: float = 3.0
@export var attack_telegraph_time: float = 0.8 # Time window to detect attack windup

func tick(actor: Node, blackboard: Blackboard) -> int:
	# Check for incoming melee attacks from player
	var player_position = blackboard.get_value("player_position", Vector3.ZERO)
	var actor_position = actor.global_position
	
	# Check if player is within melee range
	var distance_to_player = actor_position.distance_to(player_position)
	if distance_to_player > detection_range:
		return FAILURE
	
	# Check if player is performing a melee attack
	var player_attacking = blackboard.get_value("player_is_attacking", false)
	var player_attack_windup = blackboard.get_value("player_attack_windup", false)
	
	# Detect attack through various methods
	if detect_player_attack_telegraph(actor, blackboard):
		blackboard.set_value("incoming_attack_direction", calculate_attack_direction(actor, blackboard))
		return SUCCESS
		
	return FAILURE


func detect_player_attack_telegraph(actor: Node, blackboard: Blackboard) -> bool:
	# Check if player is in attack animation
	var player_attacking = blackboard.get_value("player_is_attacking", false)
	if player_attacking:
		return true
	
	# Method 2: Check player's facing direction and movement pattern
	var player_facing_enemy = blackboard.get_value("player_facing_enemy", false)
	var player_moving_toward_enemy = blackboard.get_value("player_moving_toward_enemy", false)
	var player_attack_input = blackboard.get_value("player_attack_input_pressed", false)
	
	if player_facing_enemy and player_moving_toward_enemy and player_attack_input:
		return true
		
	return false
	
