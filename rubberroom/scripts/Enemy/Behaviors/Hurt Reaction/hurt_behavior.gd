extends ActionLeaf

@export var animation_tree_path: String = "AnimationTree"
@export var hurt_trigger_parameter: String = "hurt_trigger"
@export var is_hurt_parameter: String = "is_hurt"
@export var hurt_reaction_time: float = 0.5
@export var knockback_force: float = 5.0
@export var enable_knockback: bool = true
@export var hurt_sound_enabled: bool = true
@export var interrupt_current_action: bool = true

var hurt_timer: float = 0.0
var hurt_started: bool = false
var initial_velocity: Vector3


func tick(actor: Node, blackboard: Blackboard) -> int:
	# Start hurt reaction if not already started
	if not hurt_started:
		start_hurt_reaction(actor, blackboard)
		hurt_started = true
		hurt_timer = hurt_reaction_time
	
	# Update timers
	var delta = actor.get_process_delta_time()
	hurt_timer -= delta
	
	# Update hurt timer in blackboard
	blackboard.set_value("hurt_timer", hurt_timer)
	
	# Apply knockback effect if enabled
	if enable_knockback and hurt_timer > (hurt_reaction_time * 0.7):
		apply_knockback_effect(actor, blackboard, delta)
	
	# Check if hurt reaction is complete
	if hurt_timer <= 0.0:
		complete_hurt_reaction(actor, blackboard)
		return SUCCESS
	
	return RUNNING


func start_hurt_reaction(actor: Node, blackboard: Blackboard) -> void:
	print("Enemy hurt reaction started")
	
	# Interrupt current actions if enabled
	if interrupt_current_action:
		interrupt_current_actions(actor, blackboard)
	
	# Trigger hurt animation in blend tree
	
	
	# Calculate knockback direction
	if enable_knockback:
		calculate_knockback_direction(actor, blackboard)
		
	# Play hurt sound
	if hurt_sound_enabled:
		play_hurt_sound(actor)

	# Trigger hurt effects here: particle effects, blood, etc.
	trigger_hurt_effects(actor, blackboard)


func complete_hurt_reaction(actor: Node, blackboard: Blackboard) -> void:
	print ("Hurt reaction complete")
	
	# Clear hurt animation state here
	
	# Reset for next use
	hurt_started = false
	
	# Clear hurt state from blackboard (handled by condition node)
	# blackboard.set_value("is_hurt", false)


func interrupt_current_actions(actor: Node, blackboard: Blackboard) -> void:
	# Stop any current movement
	if actor.has_method("set_velocity"):
		initial_velocity = actor.velocity if actor.has_method("get_velocity") else Vector3.ZERO
		actor.set_velocity(Vector3.ZERO)
	
	# Interrupt attack animations/actions
	blackboard.set_value("current_attack_interrupted", true)
	
	# Stop any reload or item pickup actions
	blackboard.set_value("action_interrupted", true)


func calculate_knockback_direction(actor: Node, blackboard: Blackboard) -> void:
	var damage_source_pos = blackboard.get_value("last_damage_source_position", Vector3.ZERO)
	
	if damage_source_pos != Vector3.ZERO:
		# Calculate knockback direction (away from damage source)
		var knockback_direction = (actor.global_position - damage_source_pos).normalized()
		knockback_direction.y = 0
		
		blackboard.set_value("knockback_direction", knockback_direction)
	else:
		# Default backward knockback if no source position
		var actor_forward = -actor.global_transform.basis.z
		blackboard.set_value("knockback_direction", -actor_forward)


func apply_knockback_effect(actor: Node, blackboard: Blackboard, delta: float) -> void:
	var knockback_direction = blackboard.get_value("knockback_direction", Vector3.ZERO)
	
	if knockback_direction != Vector3.ZERO and actor.has_method("set_velocity"):
		# Apply knockback force with falloff over time
		var time_ratio = hurt_timer / hurt_reaction_time
		var current_knockback = knockback_direction * knockback_force * time_ratio
		
		# Apply knockback velocity
		if actor.has_method("get_velocity"):
			var current_velocity = actor.get_velocity()
			current_velocity += current_knockback * delta
			actor.set_velocity(current_velocity)
	
func play_hurt_sound(actor: Node) -> void:
	var audio_player = actor.get_node_or_null("AudioStreamPlayer3D")
	
	if audio_player:
		# Multiple sounds can be played and randomized
		var hurt_sounds = [
			preload("res://assets/sounds/Punch Sound Effect - Gaming SFX.mp3")
		]
		
		if hurt_sounds.size() > 1:
			var random_sound = hurt_sounds[randi() % hurt_sounds.size()]
			audio_player.stream = random_sound
			audio_player.play()
		else:
			audio_player.stream = hurt_sounds[0]
			audio_player.play()


func trigger_hurt_effects(actor: Node, blackboard: Blackboard) -> void:
	pass
