extends CharacterBody3D
class_name Enemy

# AMONGUS?????
signal attacking(attack : Attack)

#Animation Control ENUM
enum {IDLE, WALK, RUN, ATTACK}
var curAnim = IDLE


# Scene reference variables

@onready var nav_agent = $NavigationAgent3D
@onready var detection_area = $DetectionArea
@onready var melee_range: Area3D = $MeleeRange
@onready var player = %Player
@onready var eyes = $Eyes
@onready var raycast = $"Line of Sight"
@onready var lock_on_point = $"Lock-On Point"
@onready var lock_on_marker = $"Lock-On Point/Lock On Marker"
@onready var enemy_stats = $"Stat Bars Enemy"
@onready var enemy_health_bar = $"Stat Bars Enemy/SubViewport/Panel/HealthBar"
@onready var anim_tree: AnimationTree = $"Animation Control/AnimationTree"
@onready var anim_player = $"Animation Control/AnimationPlayer"
@onready var right_arm_collision: CollisionShape3D = $AuxScene/Node/Skeleton3D/RightArm/Area3D/RightArmCollision
@onready var left_arm_collision: CollisionShape3D = $AuxScene/Node/Skeleton3D/LeftArm/Area3D/LeftArmCollision
# Export variables
@onready var punch_sound = $AudioStreamPlayer3D
var vision_cone

@export var SPEED = 1.5
@export var RUN_SPEED = 5.0
@export var TURN_SPEED = 3.0
@export var current_speed : float

# Boolean variables
var is_locked_on : bool = false
var is_spotted : bool = false
var is_chasing : bool = false
var is_in_range : bool = false
var is_alive : bool = true
var on_attack_cooldown : bool = false
var rotate_self : bool = true
var can_see_player : bool = false # Tracks if enemy can see player
var player_in_detection_area : bool = false # Tracks if player is in detection area

# Vision cone parameters (adjustable in Inspector or code)
@export var fov_angle : float = 60.0 # Field of view in degrees
@export var view_range : float = 50.0 # Maximum distance in units
@export var ray_count : int = 10 # Number of rays (resolution)
@export var check_interval : float = 0.2 # Time between checks (for performance)

var health_component : HealthComponent
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var target = null
var rotate_node : Node3D = null
var rotate_target : Vector3 = Vector3.ZERO

#Animation Variables / Combo Vars
var is_idle     = true
var is_walking  = false
var is_running  = false
var is_crouched = false
var is_in_combat= true
var player_spotted = false
var can_jump    = false
var in_light_combo= false
var in_heavy_combo= false
var new_state 
var lastAnim = -1  # Use an invalid enum value to ensure a state change on first frame
var hitbox_active = false  # Only allow hits if this is true

var combo_index = 0
var combo_timer = 0.0
const MAX_COMBO_WINDOW = 1.35 # 400 ms window for the next attack


var is_hitstunned: bool = false
var hitstun_duration: float = 1.5  # Adjust as needed for enemy hitstun duration

var behavior_tree : BeehaveTree
var check_timer: float = 0.0 # Timer for vision cone checks

# Inventory
var inventory : Inventory

# Weapon System
@export var current_weapon : WeaponResource
var ammo_manager = AmmoManager

@export var current_weapon_model: Node3D = null


# This function now sets curAnim based on your boolean animation variables.
func update_animation_state():
	# If currently attacking, keep that state until it finishes.
	if curAnim == ATTACK:
		return
	# Set state based on priority: running > walking > idle.
	if is_running:
		curAnim = RUN
	elif is_walking:
		curAnim = WALK
	elif is_idle:
		curAnim = IDLE


func handle_animations(curAnim):
	# Only request a transition if the new state differs from the last one.
	if curAnim != lastAnim:
		match curAnim:
			IDLE:
				anim_tree.set("parameters/Movement/transition_request" , "Idle")
			WALK:
				anim_tree.set("parameters/Movement/transition_request" , "Walking")
			RUN:
				anim_tree.set("parameters/Movement/transition_request" , "Running")
			#ATTACK:
				#anim_tree.set("parameters/Movement/transition_request" , "ComboBreaker")
		
		lastAnim = curAnim

func get_lightattack_animation() -> bool:
	return anim_tree["parameters/LightAttack/active"]
	
func get_heavyattack_animation() -> bool:
	return anim_tree["parameters/HeavyAttack/active"]

func _ready():
	current_speed = SPEED
	is_chasing = false
	health_component = HealthComponent.new()
	detection_area.connect('is_detected', alert)
	melee_range.connect('range', on_in_melee_range)
	melee_range.connect('shot_at', on_shot_at)
	player.connect("player_attacking", _on_player_attacking)
	
	behavior_tree = get_node_or_null("BasicEnemyBehaviorTree")
	player = get_node_or_null("%Player")
	if player == null:
		print(self.name, ": player is null on ready.")
	if behavior_tree == null:
		print(self.name, ": behavior tree is null on ready.")
	else:
		behavior_tree.blackboard.set_value("player", player)
		behavior_tree.blackboard.set_value("can_see_player", can_see_player)
	
	vision_cone = eyes.get_child(0)


func _physics_process(delta: float):
	update_animation_state()
	#Only Change animation on state change
	if curAnim != lastAnim:
		handle_animations(curAnim)
		lastAnim = curAnim
	#Note From Ryan: This is just here so that I can make it work for now, if we need to 
	#give this thing a new home after its fine. But for now, this is how it will work
	#print("Enemy States: is_idle: ", is_idle)
	#print("Enemy States: is_walking: ", is_walking)
	#print("Enemy States: is_running: ", is_running)
	#print("Enemy States: can_jump: ", can_jump)
	#print("Enemy States: Player Spotted: ", player_spotted)
	#print("Enemy States: Is_In_Range: ", is_in_range)
	#print("Hitbox_Active: ", hitbox_active)
	
	
	if combo_timer > 0:
		combo_timer -= delta
		if combo_timer <= 0:
			# Time’s up, reset the combo
			combo_index = 0
		#Reset Combo States after Timer Clears
	if combo_index == 0:
		in_light_combo = false
		in_heavy_combo = false
		#print("Combos Reset!")




	if health_component.health <= 0:
		is_alive = false
	
	
	if !is_alive:
		queue_free()
		
	# Handle gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0
	
	# Create an ImmediateMesh to draw the cone
	var mesh = ImmediateMesh.new()
	vision_cone.mesh = mesh
	
	# Begin drawing lines
	mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	
	# Set color based on whether player is visible
	mesh.surface_set_color(Color.GREEN if can_see_player else Color.RED)
	
	# Calculate cone parameters
	var half_fov = deg_to_rad(fov_angle / 2)
	var forward = -global_transform.basis.z.normalized() # Enemy's forward direction
	var ray_start = eyes.global_position if eyes else global_position
	
	# Draw each ray
	for i in range(ray_count):
		var t = float(i) / (ray_count - 1) if ray_count > 1 else 0.5
		var angle = lerp(-half_fov, half_fov, t)
		var ray_direction = forward.rotated(global_transform.basis.y.normalized(), angle).normalized()
		var ray_end = ray_start + ray_direction * view_range
		
		# Transform positions to local space of the DebugVisionCone node
		var local_start = vision_cone.to_local(ray_start)
		var local_end = vision_cone.to_local(ray_end)
		
		# Add vertices for the line
		mesh.surface_add_vertex(local_start)
		mesh.surface_add_vertex(local_end)
	
	# End drawing
	mesh.surface_end()
	
	# Update vision cone when player has reached the detection area
	if player_in_detection_area:
		check_timer -= delta
		if check_timer <= 0:
			check_timer = check_interval
			update_vision_cone()
	
	# Update blackboard with can_see_player
	if behavior_tree:
		behavior_tree.blackboard.set_value("can_see_player", can_see_player)
		behavior_tree.blackboard.set_value("player_pos", player.global_position)
	
	# Check if target is reached
	if nav_agent.is_target_reached():
		velocity.x = 0
		velocity.z = 0
	else:
		# Move towards the next path position
		var next_pos = nav_agent.get_next_path_position()
		var direction = (next_pos - global_position).normalized()
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	
	# Apply movement
	move_and_slide()
	
	if rotate_self:
		if is_locked_on:
			# When locked on, rotate to face the player directly.
			rotate_target = player.global_position
		elif rotate_node != null:
			rotate_target = rotate_node.global_position
		else:
			rotate_target = nav_agent.get_next_path_position()
		rotate_to_look(rotate_target, delta)
	
	if is_locked_on == false:
		lock_on_marker.hide()
		enemy_stats.hide()
	elif is_locked_on == true:
		lock_on_marker.show()
		enemy_stats.show()

# Vision cone logic
func update_vision_cone():
	# Reset visibility
	can_see_player = false
	
	# Get the physics space
	var space_state = get_world_3d().direct_space_state
	
	# Early exit if player is too far
	var to_player = player.global_position - global_position
	if to_player.length() > view_range:
		return
	
	# Check if player is within FOV angle
	var forward = -global_transform.basis.z.normalized() # Enemy's forward direction
	var angle_to_player = forward.angle_to(to_player.normalized())
	if rad_to_deg(angle_to_player) > fov_angle / 2:
		return
	
	# Generate rays in a cone
	var half_fov = deg_to_rad(fov_angle / 2)
	for i in range(ray_count):
		# Calculate angle for this ray
		var t = float(i) / (ray_count - 1) if ray_count > 1 else 0.5
		var angle = lerp(-half_fov, half_fov, t)
		
		# Rotate forward vector to create ray direction
		var ray_direction = forward.rotated(global_transform.basis.y.normalized(), angle).normalized()
		
		# Define ray start and end (start from eyes for realism)
		var ray_start = eyes.global_position if eyes else global_position
		var ray_end = ray_start + ray_direction * view_range
		
		# Create ray query
		var query = PhysicsRayQueryParameters3D.create(ray_start, ray_end)
		query.exclude = [self] # Exclude the enemy
		query.collision_mask = 1 | 2 # Player (layer 1) and walls (layer 2)
		
		# Cast the ray
		var result = space_state.intersect_ray(query)
		
		# Check if ray hits the player
		if result and result.collider == player:
			can_see_player = true
			break
	
	# Debug output
	#if can_see_player:
		#print(self.name, ": Player is visible in vision cone!")
	#else:
		#print(self.name, ": Player is not visible.")

# Idle state
func idle():
	# Stop moving
	current_speed = 0

# Rotate eyes to target position
func rotate_to_look(pos : Vector3, _delta : float):
	# optional, makes the enemy not rotate vertically
	pos.y = global_position.y
	
	# If the rotation is reached, return
	if global_transform.origin.is_equal_approx(pos) or pos == Vector3.ZERO:
		return
		
	
	# Smoothly rotate to look at next path position
	global_transform.basis = global_transform.basis.slerp(global_transform.looking_at(pos, Vector3.UP).basis, _delta * TURN_SPEED)

func new_random_position() -> Vector3:
	var nav_region = get_tree().get_nodes_in_group("nav region")[0] as NavigationRegion3D
	if not nav_region or not nav_region.navigation_mesh:
		print("Warning: NavigationRegion3D or NavigationMesh missing! Falling back to player position.")
		var fallback_pos = player.global_position + Vector3(randf_range(-10, 10), 0, randf_range(-10, 10))
		return NavigationServer3D.map_get_closest_point(nav_agent.get_navigation_map(), fallback_pos)

	var aabb = nav_region.navigation_mesh.filter_baking_aabb
	var nav_map = nav_agent.get_navigation_map()
	var attempts = 10

	for i in range(attempts):
		var random_x = randf_range(aabb.position.x, aabb.position.x + aabb.size.x)
		var random_z = randf_range(aabb.position.z, aabb.position.z + aabb.size.z)
		var random_pos = Vector3(random_x, global_position.y, random_z)
		var closest_point = NavigationServer3D.map_get_closest_point(nav_map, random_pos)
		var distance_to_player = closest_point.distance_to(player.global_position)
		if distance_to_player >= 5.0 and distance_to_player <= 20.0:
			return closest_point

	var fallback_pos = player.global_position + Vector3(randf_range(-10, 10), 0, randf_range(-10, 10))
	return NavigationServer3D.map_get_closest_point(nav_map, fallback_pos)
	#var random_position : Vector3
	#
	## Choose a random position relative to the player, so it does not seem like the enemy is actually chasing the player.
	#random_position = Vector3(randf_range(player.position.x - 40, player.global_position.x + 40), position.y, randf_range(player.position.z - 40, player.global_position.z + 40))
	## Clamps the random position to the boundaries of the world (currently 100, 100 subtract by 5 for wiggle room)
	#random_position.x = clamp(random_position.x, -40, 40)
	#random_position.z = clamp(random_position.z, -40, 40)
	#
	#return random_position



func alert(new_target):
	target = new_target


func attack() -> bool:
	#Play one hit of light combo per fire
	hitbox_active = true
	anim_tree.set("parameters/LightAttack/request" , AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	return get_lightattack_animation()

func take_damage(attack : Attack):
	health_component.damage(attack)
	
func on_in_melee_range(in_range : bool):
	is_in_range = in_range

# Update the current path and velocity
#func update_nav_agent(speed : float = 1):
	#var next_location = nav_agent.get_next_path_position()
	#var current_location = global_transform.origin
	#var new_velocity = (next_location - current_location).normalized() * current_speed
	#if nav_agent.distance_to_target() < 0.5:  # Stop if close to target
		#velocity = Vector3.ZERO
		#nav_agent.set_velocity(Vector3.ZERO)
		#return
		#
	## Sets the velocity value for the nav_agent to calculate a safe direction (see _on_navigation_agent_3d_velocity_computed
	#nav_agent.set_velocity(new_velocity * speed)

## Updates the Navigation Agent's targetted vector position. distance_to_target allows for the changing of 
## where the agent needs to stop to be considered at the target_location.
func update_target_location(target_location, distance_to_target : float = 0.7) -> void:
	#print(self.name + ": Updating enemy target location...")
	nav_agent.target_position = target_location
	nav_agent.target_desired_distance = distance_to_target

## If the enemy has reached its target, stop moving
#func _on_navigation_agent_3d_target_reached() -> void:
	#print(self.name + ": Target reached.")
	#nav_agent.set_velocity(Vector3.ZERO)
#
## Set velocity to a safe velocity for moving around enemies (must adjust)
#func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	#velocity = velocity.move_toward(safe_velocity, .90)
	#move_and_slide()
	
func update_lock_on_status():
	#Once "Locked On" Signal Received Via Player Hitting Middle Mouse
	#Turn is_locked_on to true
	#same "Locked On Signal Should change state for player as well
	pass


func _on_player_attacking(attack: Attack, in_range : bool, weapon : Item):
	if behavior_tree:
		behavior_tree.blackboard.set_value("is attacked", true)
		behavior_tree.blackboard.set_value("player attack", attack)
		
		if weapon.classification == Item.Classification.RANGED:
			behavior_tree.blackboard.set_value("is shot", true)
	
	#take_damage(attack)
	#anim_tree.set("parameters/GotHit/request" , AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	#print("Received player_attacking signal with: ", attack, ", in_range: ", in_range)
	#enemy_health_bar._on_health_changed(health_component.health)
	#apply_hitstun(hitstun_duration)
	#punch_sound.play()
	#print("Current Enemy Health: ", health_component.get_health())
		


func _on_enemy_melee_range_exited(body):
	pass # Replace with function body.

# If the player enters the melee range of this enemy, the enemy will attempt to attack
# I believe this funciton is redundant and may cause problems.
# Commenting out for now as its useless
#func _on_area_3d_body_entered(body: Node3D) -> void:
	#print("Active Hitbox? : ", hitbox_active)
	#if body.is_in_group("player") and hitbox_active:
		#var attack : Attack = Attack.new()
		#emit_signal("attacking", attack)
		#print("Right arm collided with Enemy! Dealing damage once.")
		#hitbox_active = false  # no more hits this swing
		
func apply_hitstun(duration: float) -> void:
	is_hitstunned = true
	# Optionally: play a hitstun animation or effect here.
	await get_tree().create_timer(hitstun_duration).timeout
	is_hitstunned = false

# If the enemy detects through the melee range collision area that its being
# shot at, set a blackboard value for it to true.
func on_shot_at(is_shot : bool) -> void:
	behavior_tree.blackboard.set_value("is shot at" , true)


func pickup_weapon(new_weapon : WeaponResource):
	if inventory.get_size() == 0:
		print("Inventory Full!")
		return
	else:
		inventory.add_item(new_weapon)
		print(new_weapon.name, " added to Enemy inventory.")
		#equip_weapon(new_weapon)


#func equip_weapon(new_weapon : WeaponResource):
	#if current_weapon_model:
		#weapon_attachment.remove_child(current_weapon_model)
		#current_weapon_model.queue_free()
		#current_weapon_model = null
	#current_weapon = new_weapon
	#emit_signal("weapon_changed", current_weapon)
	#
	## Set hitbox based on weapon state
	#if new_weapon.classification == Item.Classification.UNARMED:
		#current_hitbox = right_arm_collision  # Use arm hitbox for unarmed
	#else:
		#if new_weapon.model_scene:
			#current_weapon_model = new_weapon.model_scene.instantiate()
			#print("Instantiated model: ", current_weapon_model)  # Debug: Is it instantiated?
			#weapon_attachment.add_child(current_weapon_model)
			#current_weapon_model.rotation_degrees = Vector3(90, 90, 0)  # Adjust rotation to align with hand
			#current_weapon_model.position = Vector3(0, 10, 5)  # Fine-tune position if needed
			#current_weapon_model.scale = Vector3(20, 20, 20)
			#print("Parent after add: ", current_weapon_model.get_parent())  # Debug: Is it attached?
			#current_hitbox = current_weapon_model.get_node("Hitbox")
			## Find muzzle position in the weapon model
			#muzzle_position = current_weapon_model.get_node("MuzzlePosition") if current_weapon_model.has_node("MuzzlePosition") else null
			#if not muzzle_position:
				#print("Warning: MuzzlePosition not found in weapon model!")
		## Initialize ammo for ranged weapons
	#if new_weapon is Ranged:
		#ammo_manager.set_current_weapon(new_weapon)
		## Optional: If it's a new weapon type, you might want to auto-reload here
		#if ammo_manager.current_magazine <= 0:
			#ammo_manager.reload()
	#
	##Make Equip Sound on equip
		## Check and play equip sound
	## Update the equip_sound_stream when equipping a new weapon
	#if current_weapon.sound_equip:
		#firing_sound.stream = current_weapon.sound_equip  # Assign the AudioStream to the player
		#firing_sound.play()  # Play the sound
	#else:
		#equip_sound = null
	## Connect hitbox signal
	#if current_hitbox:
		#current_hitbox.body_entered.connect(_on_hitbox_entered)
	#
	##if new_weapon.classification != WeaponResource.Classification.UNARMED:
		##if new_weapon.model_scene:
			##current_weapon_model = new_weapon.model_scene.instantiate()
			##weapon_attachment.add_child(current_weapon_model)
	#print("Equipped weapon: ", new_weapon.name)


func _on_detection_area_new_weapon_found(location: Vector3) -> void:
	behavior_tree.blackboard.set_value("new weapon location", location)
	behavior_tree.blackboard.set_value("new weapon found", true)
