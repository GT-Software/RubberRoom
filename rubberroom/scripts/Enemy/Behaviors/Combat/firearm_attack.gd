extends ActionLeaf

@export var aim_time: float = 0.5
@export var fire_rate: float = 2.0 # Shots per second
@export var accuracy: float = 0.8
@export var recoil_recovery_time: float = 0.3

var aim_timer: float = 0.0
var fire_timer: float = 0.0
var recoil_timer: float = 0.0
var is_aiming: bool = false

func tick(actor: Node, blackboard: Blackboard) -> int:
	var current_weapon = blackboard.get_value("current_weapon", null)
	var player_position = blackboard.get_value("player_position", Vector3.ZERO)
	
	if not current_weapon or not current_weapon.has_method("fire"):
		return FAILURE
	
	var delta = get_process_delta_time()
	
	# Handle recoil recovery
	if recoil_timer > 0:
		recoil_timer -= delta
		return RUNNING
	
	# Aim at player
	_aim_at_target(actor, player_position)
	
	# Handle aiming time
	if not is_aiming:
		is_aiming = true
		aim_timer -= delta
		return RUNNING
	
	# Fire weapon
	var hit_chance = accuracy + randf_range(-0.2, 0.2)
	if randf() <= hit_chance:
		current_weapon.fire(player_position)
		# Apply recoil and fire rate
		recoil_timer = recoil_recovery_time
		fire_timer = 1.0 / fire_rate
		is_aiming = false
		return SUCCESS
	else:
		# Missed shot
		var miss_direction = player_position + Vector3(randf_range(-2, 2), randf_range(-1, 1), randf_range(-2, 2))
		current_weapon.fire(miss_direction)
		recoil_timer = recoil_recovery_time
		fire_timer = 1.0 / fire_rate
		is_aiming = false
		return SUCCESS


func _aim_at_target(actor: Node, target_position: Vector3):
	var direction = (target_position - actor.global_position).normalized()
	var target_rotation = atan2(direction.x, direction.z)
	actor.rotation.y = lerp_angle(actor.rotation.y, target_rotation, 5.0 * get_process_delta_time())
