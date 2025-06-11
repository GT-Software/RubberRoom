extends ActionLeaf

@export var drop_items_on_death : bool = false

var death_timer: float = 0.0
var death_duration : float = 3.0
var death_started : bool = false

func tick(actor: Node, blackboard: Blackboard) -> int:
	if not death_started:
		start_death_sequence(actor, blackboard)
		death_started = true
		death_timer = 0.0
	
	death_timer += get_process_delta_time()
	
	if death_timer >= death_duration:
		complete_death(actor, blackboard)
		return SUCCESS
		
	# Death sequence is still running
	return RUNNING


func start_death_sequence(actor: Node, blackboard: Blackboard) -> void:
	print("Enemy is dying...")
	
	# Set death state in blackboard
	blackboard.set_value("is_dead", true)
	blackboard.set_value("health", 0.0)
	
	# Trigger death animation here

	# Stop any movement
	actor.set_velocity(Vector3.ZERO)
	
	# Disable collisions (make enemy non-solid)
	var collision_shape = actor.get_node_or_null("Body Collision")
	if collision_shape:
		collision_shape.disabled = true
		
	# Drop items if enabled
	if drop_items_on_death:
		drop_inventory_items(actor, blackboard)


func complete_death(actor: Node, blackboard: Blackboard) -> void:
	print("Enemy death sequence complete")
	
	# Mark as completely dead
	blackboard.set_value("death_complete", true)
	
	# Optional: Queue the actor for deletion after a delay
	# actor.queue_free()
	
	# Or hide the actor and disable it completely
	actor.visible = false
	actor.set_process(false)
	actor.set_physics_process(false)


func drop_inventory_items(actor: Node, blackboard: Blackboard) -> void:
	var current_weapon = blackboard.get_value("current_weapon", null)
	
	if current_weapon != null:
		#Drop the current weapon
		print("Dropping weapon: ", current_weapon.name)
		
		# Create weapon drop logic here
	
	# Clear weapon from blackboard
	blackboard.set_value("current_weapon", null)
