extends CharacterBody3D

# -------------------------------
# Signals
# -------------------------------
signal stamina_change(new_stamina)
signal health_change
signal stun_change
signal fear_change
signal player_attacking(attack : Attack, in_range : bool)
# -------------------------------
# Node references
# -------------------------------
@onready var canvas_layer = $"../CanvasLayer"
@onready var ap = $AuxScene/AnimationPlayer
@onready var ap_tree = $"Animation Control/AnimationTree"
@onready var ap_tree_2: AnimationTree = $"Animation Control/AnimationTree2"

@onready var player_stat_bars = $"../CanvasLayer/Player Stat Bars"
@onready var health_bar     = $"../CanvasLayer/Player Stat Bars/HealthBar"
@onready var stun_bar       = $"../CanvasLayer/Player Stat Bars/StunBar"
@onready var stamina_bar    = $"../CanvasLayer/Player Stat Bars/StaminaBar"
@onready var fear_bar       = $"../CanvasLayer/Player Stat Bars/FearBar"
@onready var _player_pcam   = $"../Camera Controller/PhantomCamera3D"
@onready var _aim_pcam = $"../Camera Controller/PhantomCamera Zoom In"
@onready var right_arm_collision = $AuxScene/Node/Skeleton3D/RightArm/Area3D/RightArmCollision
@onready var left_arm_collision = $AuxScene/Node/Skeleton3D/LeftArm/Area3D/LeftArmCollision

@onready var punch_sound = $AudioStreamPlayer3D


@onready var camera_anchor: Node3D = $"RotationPoint/Camera Anchor"
@onready var rotation_point: Node3D = $RotationPoint
@onready var tween: Tween = Tween.new()
@onready var weapon_attachment: BoneAttachment3D = $AuxScene/Node/Skeleton3D/RightArm


# Weapon system
@export var unarmed_weapon: WeaponResource
var current_weapon: WeaponResource
var current_weapon_model: Node3D = null

@export var mouse_sensitivity: float = 0.05
@export var min_pitch: float = -89.9
@export var max_pitch: float = 50
@export var min_yaw: float = 0
@export var max_yaw: float = 360
@export var aim_min_pitch: float = -44.9
@export var aim_max_pitch: float = 25
@export var aim_min_yaw: float = 0
@export var aim_max_yaw: float = 360
@export var stamina_regen_rate: float = 0.50
@export var lock_on_max_yaw_deviation: float = 15.0   # in degrees
@export var lock_on_max_pitch_deviation: float = 10.0 # in degrees



#@export var lock_on_button = "lock_on"  # Name of your input action (e.g., "middle mouse")



# -------------------------------
# Components
# -------------------------------
var health_component : HealthComponent = HealthComponent.new()
var stun_component   : StunComponent   = StunComponent.new()
var stamina_component: StaminaComponent= StaminaComponent.new()
var fear_component   : FearComponent   = FearComponent.new()

# Movement constants
const FIGHTSPEED   = 2.5
const SPEED        = 5.0
const RUN_SPEED    = 15.0
const CROUCH_SPEED = 1.0
const JUMP_VELOCITY= 5.0

# -------------------------------
# Animation Vars
# -------------------------------
var is_idle     = false
var is_walking  = false
var is_running  = false
var locked_on   = false
var is_crouched = false
var is_in_combat= true
var can_jump    = false
var in_light_combo= false
var in_heavy_combo= false
var got_hit_light = false
var got_hit_heavy = false
var new_state 
var lastAnim = -1  # Use an invalid enum value to ensure a state change on first frame
var hitbox_active = false  # Only allow hits if this is true

var current_combo_index = 0

enum AttackType { NONE, LIGHT, HEAVY, RANGED, THROWABLE }
var current_attack_type : int = AttackType.NONE
var combo_index : int = 0         # Unified combo index
var combo_timer : float = 0.0       # Timer for buffering next attack
const MAX_COMBO_WINDOW = 1.35       # Seconds to input next attack

# Max hits for each combo type (adjust as needed)
const MAX_LIGHT_COMBO_HITS = 3
const MAX_HEAVY_COMBO_HITS = 2

# Buffer flags
var buffered_attack : bool = false   # Set when input is detected during an active combo
var can_buffer_attack : bool = false # Set via timeline (animation call) to open the input window



# New variable for dynamic hitbox
var current_hitbox: Area3D


var default_fov : float = 75.0
var locked_on_fov : float = 60.0

var lock_on_base_yaw: float = 0.0
var lock_on_base_pitch: float = 0.0

var default_anchor_offset: Vector3
var combat_anchor_offset: Vector3 = Vector3(1.15, 0.75, 1.15)  # adjust to your desired combat offset

var is_hitstunned: bool = false
var hitstun_duration: float = 1.5  # Adjust duration as needed
#Animation Control ENUM
enum {IDLE, WALK, RUN, ATTACKLight, ATTACKHeavy, JUMP, GOTHIT}
var curAnim = IDLE

func update_animation_state():
	# If currently attacking, keep that state until it finishes.
	if curAnim == ATTACKLight:
		return
	# Set state based on priority: running > walking > idle.
	if is_running:
		curAnim = RUN
	elif is_walking:
		curAnim = WALK
	elif is_idle:
		curAnim = IDLE
	elif in_light_combo:
		curAnim = ATTACKLight
	elif in_heavy_combo:
		curAnim = ATTACKHeavy

func handle_animations(curAnim):
	# Only request a transition if the new state differs from the last one.
	if curAnim != lastAnim:
		match curAnim:
			IDLE:
				ap_tree_2.set("parameters/Movement/transition_request" , "Idle")
			WALK:
				ap_tree_2.set("parameters/Movement/transition_request" , "Walking")
			RUN:
				ap_tree_2.set("parameters/Movement/transition_request" , "Running")
			ATTACKLight:
				ap_tree_2.set("parameters/Movement/transition_request" , "AttackingLight")
			ATTACKHeavy:
				ap_tree_2.set("parameters/Movement/transition_request" , "AttackingHeavy")
		
		lastAnim = curAnim


# -------------------------------
# Timers/Cooldowns
# -------------------------------
@onready var dodge_timer: Timer = $"Dodge Timer"
@onready var dodge_cooldown: Timer = $"Dodge Cooldown"
@onready var block_cooldown: Timer = $"Block Cooldown"

# -------------------------------
# Dodge Configuration
# -------------------------------
var dodge_speed = 10.0
var is_dodging = false
var dodging_on_cooldown = false
var dodge_direction = Vector3.ZERO
var dodge_stamina_drain = 2.0

# -------------------------------
# Block Configuration
# -------------------------------
var is_blocking = false
var blocking_on_cooldown = false
var cannot_take_damage = false
var take_chip_damage = false
var chip_damage_percent = 0.20

var locked_on_enemy: Enemy = null  # Reference to the currently locked-on enemy


var current_speed = 0.0

# Gravity from ProjectSettings
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var _velocity = Vector3.ZERO

@onready var _spring_arm : SpringArm3D     = $SpringArm3D

var move_direction = Vector3.ZERO

var is_in_range = true
var enemy

func _ready():
	health_bar.init_health(health_component)
	stun_bar.init_stun(stun_component)
	stamina_bar.init_stamina(stamina_component)
	fear_bar.init_fear(fear_component)
	rotation_point.set_as_top_level(true)
	 # Store the initial camera anchor position as the default offset.
	default_anchor_offset = camera_anchor.position
	current_weapon = unarmed_weapon  # Set default to unarmed
	#add_child(tween)
	var knife_res = load("res://Resources/Weapons/knife.tres")
	if knife_res:
		equip_weapon(knife_res)
	


# Weapon equipping function
func equip_weapon(new_weapon: WeaponResource) -> void:
	if current_weapon_model:
		weapon_attachment.remove_child(current_weapon_model)
		current_weapon_model.queue_free()
		current_weapon_model = null
	current_weapon = new_weapon
	
	# Set hitbox based on weapon state
	if new_weapon.classification == WeaponResource.Classification.UNARMED:
		current_hitbox = right_arm_collision  # Use arm hitbox for unarmed
	else:
		if new_weapon.model_scene:
			current_weapon_model = new_weapon.model_scene.instantiate()
			print("Instantiated model: ", current_weapon_model)  # Debug: Is it instantiated?
			weapon_attachment.add_child(current_weapon_model)
			current_weapon_model.rotation_degrees = Vector3(90, 90, 0)  # Adjust rotation to align with hand
			current_weapon_model.position = Vector3(0, 10, 5)  # Fine-tune position if needed
			current_weapon_model.scale = Vector3(100, 100, 100)
			print("Parent after add: ", current_weapon_model.get_parent())  # Debug: Is it attached?
			current_hitbox = current_weapon_model.get_node("Hitbox")
	
	# Connect hitbox signal
	if current_hitbox:
		current_hitbox.body_entered.connect(_on_hitbox_entered)
	
	#if new_weapon.classification != WeaponResource.Classification.UNARMED:
		#if new_weapon.model_scene:
			#current_weapon_model = new_weapon.model_scene.instantiate()
			#weapon_attachment.add_child(current_weapon_model)
	print("Equipped weapon: ", new_weapon.name)



func _physics_process(delta):
	if is_hitstunned:
		velocity = Vector3.ZERO
		return  # Skip the rest of the process function
	
	
	update_animation_state()
	#Only Change animation on state change
	if curAnim != lastAnim:
		handle_animations(curAnim)
		lastAnim = curAnim
		
	# Adjust camera distance based on lock-on state
	if locked_on:
		_player_pcam.fov = lerp(_player_pcam.fov, locked_on_fov, 0.1)
	else:
		_player_pcam.fov = lerp(_player_pcam.fov, default_fov, 0.1)

	#print_debug("")
	#---------------------------------
	# 1) Gravity + Death check
	#---------------------------------
	if health_component.get_health() <= 0:
		queue_free()
	
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	if is_on_floor():
		can_jump = false

	#---------------------------------
	# 2) Jump
	#---------------------------------
	if is_on_floor() and Input.is_action_just_pressed("jump") and can_jump and not locked_on:
		can_jump = true
		velocity.y = JUMP_VELOCITY

	#---------------------------------
	# 3) Movement input
	#---------------------------------
	var input_dir = Input.get_vector("left", "right", "forward", "backward")

	# Decide if run, crouch, or normal speed
	if Input.is_action_pressed("run") and not is_crouched and stamina_component.stamina > 1:
		current_speed = RUN_SPEED
		is_walking    = false
		is_running    = true
		##For Stamina
		stamina_component.stamina_drain()
		#emit_signal("stamina_change", stamina_component.stamina)
		stamina_bar._on_stamina_changed(stamina_component.stamina)
		

	elif Input.is_action_pressed("crouch"):
		current_speed = CROUCH_SPEED
		# If you intend to toggle crouch:
		is_crouched = !is_crouched
		
	elif locked_on:
		current_speed = FIGHTSPEED
		is_walking    = true
		is_running    = false
		can_jump      = false
	else:
		current_speed = SPEED
		is_walking    = true
		is_running    = false
		can_jump      = false
	
	
# If stamina is exhausted, force walking mode (non-running)
		if stamina_component.stamina <= 0:
			current_speed = SPEED
			is_running = false
			is_walking = true
	
		# Stamina Regeneration Logic:
	# Only regenerate when the player is not running
	#Need to find correct way to trigger
	#if not Input.is_action_pressed("run"): 
	# Increase stamina by regen rate scaled by delta time
	stamina_component.stamina += stamina_regen_rate * delta
		# Clamp stamina to its maximum value. Ensure you have a 'max_stamina' property in your StaminaComponent.
	stamina_component.stamina = clamp(stamina_component.stamina, 0, stamina_component.MAX_STAMINA)
		# Update the stamina bar UI to reflect the new stamina value
	stamina_bar._on_stamina_changed(stamina_component.stamina)
	
	#---------------------------------
	# 4) Rotate input by camera yaw
	#---------------------------------
	var cam_yaw = _player_pcam.global_transform.basis.get_euler().y
	move_direction = Vector3(input_dir.x, 0, input_dir.y).rotated(Vector3.UP, cam_yaw)
	var aim_cam_yaw = _aim_pcam.global_transform.basis.get_euler().y
	move_direction = Vector3(input_dir.x, 0, input_dir.y).rotated(Vector3.UP, cam_yaw)

	#---------------------------------
	# 5) Set velocity
	#---------------------------------
	velocity.x = move_direction.x * current_speed
	velocity.z = move_direction.z * current_speed
	if is_dodging:
		velocity = dodge_direction * dodge_speed
	
	#---------------------------------
	# 8) Defense logic
	#---------------------------------
	
	# Dodge
	if Input.is_action_just_pressed("dodge") and not is_dodging and stamina_component.stamina >= 0 and not dodging_on_cooldown and locked_on:
		#print("Dodging")
		#velocity = velocity + (added_velocity * move_direction)
		start_dodge(velocity)
	
	# Block
	if Input.is_action_pressed("block"):
		start_block()
	else:
		is_blocking = false
		#print("Not Blocking!")
	
	#---------------------------------
	# 6) Move
	#---------------------------------
	move_and_slide()
	rotation_point.global_position = global_position
	
	#---------------------------------
	# 7) Attack logic
	#---------------------------------
	#if (in_light_combo or in_heavy_combo) and is_in_range:
		#var attack_instance = Attack.new(2.0, 0.0, 0.0, 0.0, 0.0, global_position)
		#print("Emitting player_attacking signal with: ", attack_instance)
		#player_attacking.emit(attack_instance, is_in_range)
	

	#---------------------------------
	# 8) Idle/walking/running detection
	#---------------------------------
	if move_direction.x == 0 and move_direction.z == 0:
		is_idle     = true
		is_walking  = false
		is_running  = false
	else:
		is_idle = false
	
	#---------------------------------
	# 9) Animations
	#---------------------------------
	
	##MOVE TO OTHER PROCESS YOU SILLY FUCK
# Decrease combo_timer if it’s > 0
	if combo_timer > 0:
		combo_timer -= delta
		if combo_timer <= 0:
			reset_combo()

		#Reset Combo States after Timer Clears
	if combo_index == 0:
		in_light_combo = false
		in_heavy_combo = false
		hitbox_active = false
		#print("Combos Reset!")
	#
	#if Input.is_action_just_pressed("light_attack"):
		#in_light_combo = true
		#hitbox_active = true
		#
		#if combo_index == 0:
			#ap_tree_2.set("parameters/LightAttack1/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
			## First hit in a light combo
			#combo_index = 1
			#combo_timer = MAX_COMBO_WINDOW
			#print("light_attack1")
			#
		#elif combo_index == 1:
			#ap_tree_2.set("parameters/LightAttack2/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
			## Already in Light Combo 1, user pressed again in time:
			#combo_index = 2
			#combo_timer = MAX_COMBO_WINDOW
			#print("light_attack2")
			#
		#elif combo_index == 2:
			#ap_tree_2.set("parameters/LightAttack3/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
			## Already in Light Combo 2
			#combo_index = 3
			#combo_timer = MAX_COMBO_WINDOW
			#print("light_attack3")
			##reset_combo()
			#
		#
			#
			## Similarly for “heavy_attack”
	#if Input.is_action_just_pressed("heavy_attack"):
		#in_heavy_combo = true
		#hitbox_active = true
		#if combo_index == 0:
			#ap_tree_2.set("parameters/HeavyAttack1/request" , AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
			#combo_index = 1
			#combo_timer = MAX_COMBO_WINDOW
			#print("Heavy_attack1")
			#ap_tree.set("parameters/Combat/ComboMachine/LeftFootForward/current", "Heavy Combo 1")
		#elif combo_index == 1:
			#ap_tree_2.set("parameters/HeavyAttack2/request" , AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
			## Already in Heavy Combo 1
			#combo_index = 2
			#combo_timer = MAX_COMBO_WINDOW
			#print("Heavy_attack2")
			#ap_tree.set("parameters/Combat/ComboMachine/LeftFootForward/current", "Heavy Combo 2")
			###Note to self, combos work now i need to "queue" them so they all play out in order
			#
	#if Input.is_action_pressed("block"):
		#is_blocking = true
		#ap_tree.set("parameters/Combat/ComboMachine/LeftFootForward/current", "StandingBlockIdle")
		#print("Blocking!")
	#else:
		#is_blocking = false
		 ## If your state machine’s “StandingBlockIdle” anim leads to “LeftBlock0” on code or user input, that’s fine,
		## or you can do something else here if you want a dedicated “block” release.
		#ap_tree.set("parameters/Combat/ComboMachine/LeftFootForward/current", "Start")  # or “Idle”
			
			
			
	if locked_on and locked_on_enemy:
	# Calculate direction from player to enemy (ignoring vertical differences)
		var enemy_pos = locked_on_enemy.global_transform.origin
		enemy_pos.y = global_transform.origin.y
		var direction = (enemy_pos - global_transform.origin).normalized()
		# Compute the target angle for the player (in radians)
		var target_angle = atan2(direction.x, direction.z) + PI
		# Smoothly interpolate player's yaw toward the enemy
		rotation.y = lerp_angle(rotation.y, target_angle, 0.1)
	else:
		if not locked_on:
			if velocity.length() > 0.2:
				var cam_euler: Vector3 = _player_pcam.global_transform.basis.get_euler()
				rotation.y = lerp_angle(rotation.y, cam_euler.y, 0.1)
				if _player_pcam.get_priority() < _aim_pcam.get_priority():
					var aim_cam_euler: Vector3 = _aim_pcam.global_transform.basis.get_euler()
					rotation.y = lerp_angle(rotation.y, aim_cam_euler.y, 0.1)
	
	
	##Lock on Master Logic
	if locked_on and locked_on_enemy:
		# Get the position of the enemy
		var enemy_pos = locked_on_enemy.global_transform.origin
		# We want to rotate rotation_point so the camera points at the enemy.
		# a) Compute direction from rotation_point to enemy
		var my_pos = rotation_point.global_transform.origin
		var direction = (enemy_pos - my_pos).normalized()
		
		# b) Compute desired yaw & pitch from direction
		var desired_yaw = rad_to_deg(atan2(direction.x, direction.z))
		var horizontal_dist = Vector2(direction.x, direction.z).length()
		var desired_pitch = -rad_to_deg(atan2(direction.y, horizontal_dist))
		# c) Lerp the current rotation to that yaw/pitch
		#    (rotation_degrees is a Vector3(x=Pitch, y=Yaw, z=Roll))
		var current_rot = rotation_point.rotation_degrees
		current_rot.y = lerp_angle(current_rot.y, desired_yaw, 0.5 * delta)
		current_rot.x = lerp_angle(current_rot.x, desired_pitch, 0.5 * delta)
		# d) Optionally clamp pitch, etc.
		current_rot.x = clampf(current_rot.x, min_pitch, max_pitch)
		rotation_point.rotation_degrees = current_rot
	else:
		# Normal camera logic when not locked on
		pass
		
	
	if locked_on and locked_on_enemy:
		# If enemy is out of range or dead, unlock
		var dist = global_position.distance_to(locked_on_enemy.global_position)
		if dist > 20 or locked_on_enemy.is_alive == false:
			unlock_enemy()
			return


func _on_hitbox_entered(body):
	if hitbox_active and body.is_in_group("enemies"):
		var attack_instance = Attack.new(current_weapon.damage, 0.0, 0.0, 0.0, 0.0, global_position)
		emit_signal("player_attacking", attack_instance, true)
		print("_on_hitbox_entered was run through")
		hitbox_active = false  # Reset after hit (adjust based on your combo system)
# -------------------------------
# Attack Functions
# -------------------------------

# Called when an attack input is first detected
func start_combo(attack_type: int) -> void:
	current_attack_type = attack_type
	combo_index = 1
	combo_timer = MAX_COMBO_WINDOW
	buffered_attack = false
	play_attack(combo_index)
# Called when a new input is detected during an active combo

func trigger_next_attack() -> void:
	if current_attack_type == AttackType.LIGHT:
		if combo_index < MAX_LIGHT_COMBO_HITS:
			combo_index += 1
			buffered_attack = false
			combo_timer = MAX_COMBO_WINDOW
			play_attack(combo_index)
			print("Buffered Light Played")
		else:
			reset_combo()
	elif current_attack_type == AttackType.HEAVY:
		if combo_index < MAX_HEAVY_COMBO_HITS:
			combo_index += 1
			buffered_attack = false
			combo_timer = MAX_COMBO_WINDOW
			play_attack(combo_index)
			print("Buffered Heavy Played")
		else:
			reset_combo()

# Play the proper animation based on the current attack type and hit index
func play_attack(hit_index: int) -> void:
	if current_attack_type == AttackType.LIGHT:
		match hit_index:
			1:
				ap_tree_2.set("parameters/LightAttack1/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
				print("light_attack1")
			2:
				ap_tree_2.set("parameters/LightAttack2/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
				print("light_attack2")
			3:
				ap_tree_2.set("parameters/LightAttack3/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
				print("light_attack3")
	elif current_attack_type == AttackType.HEAVY:
		match hit_index:
			1:
				ap_tree_2.set("parameters/HeavyAttack1/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
				print("heavy_attack1")
			2:
				ap_tree_2.set("parameters/HeavyAttack2/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
				print("heavy_attack2")


# Reset the combo once the timer expires or the max hit is reached
func reset_combo() -> void:
	current_attack_type = AttackType.NONE
	combo_index = 0
	combo_timer = 0.0
	buffered_attack = false
	can_buffer_attack = false

# -------------------------------
# Buffer Window Functions
# (These will be called from the animation timeline via Call Method tracks)
# -------------------------------
func open_buffer_window() -> void:
	can_buffer_attack = true
	# If the input was already buffered, immediately chain the next attack
	if buffered_attack:
		trigger_next_attack()

func close_buffer_window() -> void:
	can_buffer_attack = false
	# Optionally, if no input was buffered at this point, you could reset here
	# if not buffered_attack:
	#     reset_combo()

# -------------------------------
# Input & Timer Handling
# -------------------------------
func _input(event: InputEvent) -> void:
	# Light attack input
	if Input.is_action_just_pressed("light_attack"):
		hitbox_active = true
		if current_attack_type == AttackType.NONE:
			start_combo(AttackType.LIGHT)
		elif current_attack_type == AttackType.LIGHT:
			# Buffer the input if within the combo window
			buffered_attack = true
			# If the buffer window is open, trigger the next attack immediately
			if can_buffer_attack:
				trigger_next_attack()

	# Heavy attack input
	if Input.is_action_just_pressed("heavy_attack"):
		hitbox_active = true
		if current_attack_type == AttackType.NONE:
			start_combo(AttackType.HEAVY)
		elif current_attack_type == AttackType.HEAVY:
			buffered_attack = true
			if can_buffer_attack:
				trigger_next_attack()
	
	if event is InputEventMouseMotion:
		if _player_pcam.get_priority() > _aim_pcam.get_priority():
			var cam_rot = _player_pcam.get_third_person_rotation_degrees()
			
			# Pitch (X-axis)
			cam_rot.x -= event.relative.y * mouse_sensitivity
			cam_rot.x = clampf(cam_rot.x, min_pitch, max_pitch)
			# Yaw (Y-axis)
			cam_rot.y -= event.relative.x * mouse_sensitivity
			cam_rot.y = wrapf(cam_rot.y, min_yaw, max_yaw)
			_player_pcam.set_third_person_rotation_degrees(cam_rot)
			rotation_point.rotation_degrees = cam_rot
			
		elif _player_pcam.get_priority() < _aim_pcam.get_priority():
			var slow_mouse_sensitivity = mouse_sensitivity * 0.5
			var aim_cam_rot = _aim_pcam.get_third_person_rotation_degrees()
			
			# Pitch (X-axis)
			aim_cam_rot.x -= event.relative.y * slow_mouse_sensitivity
			aim_cam_rot.x = clampf(aim_cam_rot.x, aim_min_pitch, aim_max_pitch)
			# Yaw (Y-axis)
			aim_cam_rot.y -= event.relative.x * slow_mouse_sensitivity
			aim_cam_rot.y = wrapf(aim_cam_rot.y, aim_min_yaw, aim_max_yaw)
			_aim_pcam.set_third_person_rotation_degrees(aim_cam_rot)
			rotation_point.rotation_degrees = aim_cam_rot
			
		
	_toggle_aim_pcam(event)
	
	
	
	
	
	if Input.is_action_just_pressed("lock_on"):
		print("locking-on!")
		if locked_on == false:
			# 1) Lock onto the nearest or the currently “in_range” enemy
			if enemy and is_in_range:
				lock_on_to_enemy(enemy)
			else:
				 # Optionally, pick an enemy from a global list or based on detection
				var nearest_enemy = get_nearest_enemy()
				if nearest_enemy:
					lock_on_to_enemy(nearest_enemy)
		else:
			 # 2) Already locked on -> unlock
			unlock_enemy()

func _on_range_body_entered(body: Node3D) -> void:
	if body.is_in_group("enemies"):
		is_in_range = true
		enemy = body
		print("INIGO MONTOYA ACTIVATED")


func _on_range_body_exited(body: Node3D) -> void:
	is_in_range = false
	print("INIGO MONTOYA DEACTIVATED")


func _on_enemy_attacking(attack: Attack) -> void:
	# Check for blocking and do modifications to attack if there is chip damage enabled
	# Figure out animations
	if is_blocking and not take_chip_damage:
		block_cooldown.start()
		is_blocking = false
		blocking_on_cooldown = true
		print("Blocked Attack!")
		return
	elif is_blocking and take_chip_damage:
		attack.health_damage *= chip_damage_percent
		block_cooldown.start()
		is_blocking = false
		blocking_on_cooldown = true
		
	health_component.damage(attack)
	ap_tree_2.set("parameters/Got_Hit_Light/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	print("Current Health: ", health_component.get_health())
	apply_hitstun(hitstun_duration)
	punch_sound.play()
	health_bar._on_health_changed(health_component.health)



func animation_updates(current_speed, move_direction):
	if is_idle:
		ap.play("Idle(1)0")
	elif is_walking:
		ap.play("Walking(2)0")
	elif is_running:
		ap.play("Running(1)0")
		
		
func _toggle_aim_pcam(event: InputEvent) -> void:
	if Input.is_action_pressed("aim_toggle") \
		and event.is_pressed() \
		and (_player_pcam.is_active() or _aim_pcam.is_active()):
		print("Switching To Aim")
		_aim_pcam.set_third_person_rotation_degrees(_player_pcam.get_third_person_rotation_degrees())
		if _player_pcam.get_priority() > _aim_pcam.get_priority():
			_aim_pcam.set_priority(30)
		else:
			_aim_pcam.set_priority(0)


func get_nearest_enemy() -> Enemy:
	var nearest_distance := INF
	var nearest_enemy: Enemy = null
	 # Gather all nodes in the "enemies" group.
	var enemies = get_tree().get_nodes_in_group("enemies")
	for node in enemies:
		if node is Enemy:
			# Optionally skip dead or hidden enemies
			if not node.is_alive:
				continue
			# Calculate distance from the player's position
			var dist = global_position.distance_to(node.global_position)
			if dist < nearest_distance:
				nearest_distance = dist
				nearest_enemy = node
	return nearest_enemy

func lock_on_to_enemy(enemy_obj: Enemy) -> void:
	locked_on_enemy = enemy_obj
	locked_on = true
	# Tell the enemy it’s locked on
	enemy_obj.is_locked_on = true
	enemy_obj.lock_on_marker.show()
	# Set camera anchor to combat offset.
	var tween = create_tween()
	tween.tween_property(camera_anchor, "position", combat_anchor_offset, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	 # Store the current camera and rotation_point values as your clamp center.
	lock_on_base_yaw = _player_pcam.get_third_person_rotation_degrees().y
	lock_on_base_pitch = rotation_point.rotation_degrees.x


func unlock_enemy() -> void:
	if locked_on_enemy:
		locked_on_enemy.is_locked_on = false
		locked_on_enemy.lock_on_marker.hide()
	locked_on_enemy = null
	locked_on = false
	var tween = create_tween()
	# Restore the camera anchor to its default offset.
	tween.tween_property(camera_anchor, "position", default_anchor_offset, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)



# Timeout function for Dodge Timer
func _on_dodge_end() -> void:
	is_dodging = false

# Function that handles dodge mechanic
func start_dodge(move_direction : Vector3):
	is_dodging = true
	
	# Get the directional input
	var input_direction = Vector3(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		0,
		Input.get_action_strength("backward") - Input.get_action_strength("forward")
	).normalized()
	
	# Use direction player is going as dodge direction
	if move_direction != Vector3.ZERO:
		dodge_direction = (transform.basis * input_direction).normalized()
	else:
		dodge_direction = -transform.basis.z.normalized()	# Default to dodging backward
	
	stamina_component.stamina_drain(dodge_stamina_drain)
	dodging_on_cooldown = true
	dodge_timer.start()
	dodge_cooldown.start()

# Timeout out function to prevent dodge from being spammed
func _on_dodge_cooldown_timeout() -> void:
	dodging_on_cooldown = false


# Function that handles block mechanic
func start_block():
	# Conditions:
	# Is block on cooldown?
	if blocking_on_cooldown:
		print("Blocking on Cooldown!")
		return
	
	# Is player doing another action? If so what action?
	if current_action() != "running" and current_action() != "walking" and current_action() != "blocking":
		print(current_action())
		print("Action Conflict!")
		return
	
	# Does player have enough stamina?
	if stamina_component.stamina <= 0:
		print("TAKE CHIP DAMAGE RETARD")
		take_chip_damage = true
	
	# Holding Melee Weapon? If so, is it a shield (implemented when weapons are?
	
	# Perform block based on conditionals
	print("Is Blocking Retard!")
	is_blocking = true
	# Is player still blocking?
	
	# End Block


func _on_block_cooldown_timeout() -> void:
	blocking_on_cooldown = false

func current_action() -> String:
	if is_blocking:
		return "blocking"
	elif is_crouched:
		return "crouched"
	elif is_dodging:
		return "dodging"
	elif is_running:
		return "running"
	elif is_walking:
		return "walking"
	else:
		return "no action"


func _on_area_3d_body_entered(body):
	#print("Active Hitbox? : ", hitbox_active)
	# 1) Check if the collision is an Enemy
	#if not (body is Enemy):
		#return
		#
	## 2) Check if our “attack” is currently active
	#if not hitbox_active:
		#return
	
	if body.is_in_group("enemies") and hitbox_active:
			# 3) If valid, deal damage exactly once
		var attack_instance = Attack.new(current_weapon.damage, 0.0, 0.0, 0.0, 0.0, global_position)
		print("Right arm collided with Enemy! Dealing damage once: ", current_weapon.damage)
		emit_signal("player_attacking", attack_instance, true)
		hitbox_active = false  # no more hits this swing


func apply_hitstun(duration: float) -> void:
	is_hitstunned = true
	# Optionally: play a hitstun animation or effect here.
	await get_tree().create_timer(hitstun_duration).timeout
	is_hitstunned = false

## Returns the player's current attack type as a string
func get_current_attack_type():
	match current_attack_type:
		AttackType.NONE:
			return "none"
		AttackType.LIGHT:
			return "melee_light"
		AttackType.HEAVY:
			return "melee_heavy"
		AttackType.RANGED:
			return "ranged"
		AttackType.THROWABLE:
			return "throwable"
		_:
			return "unknown"

# Add an array of topics for the print_debug function to print out
func print_debug(content: Array[String]):
	for c in content:
		match c:
			"stamina":
				print("Player Stamina: ", stamina_component.stamina)
			"combo":
				print("States: combo: ", in_light_combo, in_heavy_combo)
				print("Combo Timer: ", combo_timer)
				print("Combo Index: ", combo_index)
			"stats":
				print("Player Speed: ", current_speed)
				print("Player Position: ", global_position)
				print("Rotation Point Position: ", rotation_point.global_position)
				print("Camera Point Position: ", camera_anchor.global_position)
			"animation":
				print("can buffer attack: ", can_buffer_attack)
				print("buffered_attack: ", buffered_attack)
				print("States: is_walking: ", is_walking)
				print("States: is_running: ", is_running)
				print("States: can_jump: ", can_jump)
				print("States: Is_In_Range: ", is_in_range)
				print("States: combat: ", is_in_combat)
