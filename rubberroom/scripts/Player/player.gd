extends CharacterBody3D

# -------------------------------
# Signals
# -------------------------------
signal stamina_change(new_stamina)
signal health_change
signal stun_change
signal fear_change
signal player_attacking(attack : Attack, in_range : bool, weapon : Item)
signal weapon_changed(weapon)
# -------------------------------
# Node references
# -------------------------------
@onready var canvas_layer = $"../CanvasLayer"
@onready var ap = $"Animation Control/AnimationPlayer"
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
@onready var ammo_display = $"../CanvasLayer/AmmoDisplay"
@onready var buffer_visual = $BufferVisual

@onready var punch_sound = $AudioStreamPlayer3D


@onready var camera_anchor: Node3D = $"RotationPoint/Camera Anchor"
@onready var rotation_point: Node3D = $RotationPoint
@onready var tween: Tween = Tween.new()
@onready var weapon_attachment: BoneAttachment3D = $AuxScene/Node/Skeleton3D/RightArm
@export var randomShakeStrength : float = 30.0
@export var ShakeFade : float = 5.0
var rng = RandomNumberGenerator.new()
var shake_strength : float = 0.0
# Weapon system
@export var unarmed_weapon: WeaponResource
var current_weapon: WeaponResource
var current_weapon_model: Node3D = null

# -------------------------------
# Ranged Weapon Variables
# -------------------------------
var ammo_manager = AmmoManager.new()
var fire_cooldown_timer = 0.0
var can_fire = true
var is_reloading = false
var is_aiming = false
#@onready var muzzle_position = $AuxScene/Node/Skeleton3D/RightArm/MuzzlePosition
@onready var projectile_container = $"../ProjectileContainer"  # Add this Node to your scene
@onready var firing_sound = $FiringSound  # Add AudioStreamPlayer3D to your scene
@onready var equip_sound = AudioStream
@onready var muzzle_position: Node3D = null


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


enum ComboAttackType {
	LIGHT_ATTACK_1,
	LIGHT_ATTACK_2,
	LIGHT_ATTACK_3,
	HEAVY_ATTACK_1,
	HEAVY_ATTACK_2
	# Add more as needed
}

enum AttackType { NONE, LIGHT, HEAVY, RANGED, THROWABLE }
var current_attack_type: int = AttackType.NONE
var current_phase: String = "none"
var combo_index: int = 1
var combo_timer: float = 0.0
const MAX_COMBO_WINDOW = 1.6
const MAX_LIGHT_COMBO_HITS = 3
const MAX_HEAVY_COMBO_HITS = 2

# Combo queue system

var buffered_attack: bool = false
var can_buffer_attack: bool = false
var was_buffered_canceled: bool = false
var is_attacking = false
var current_one_shot_path: String = ""  # New variable to track current one-shot


# Define attack nodes for scalability
const ATTACK_NODES = ["LightAttack1", "LightAttack2", "LightAttack3", "HeavyAttack1", "HeavyAttack2"]
# New variable for dynamic hitbox
var current_hitbox: Area3D

# Store buffer entry times for each animation
var current_animation: String = ""

# Mapping from AnimationTree node names to AnimationPlayer animation names
var default_attack_animations: Dictionary = {
	"LightAttack1": "Jab(LeftForward)0",
	"LightAttack2": "CrossPunch(LeftForward)0",
	"LightAttack3": "HookPunch(LeftForward)0",
	# Add heavy attack mappings
	"HeavyAttack1": "HookPunch(LeftForward)0",  # Replace with actual animation names
	"HeavyAttack2": "RoundhouseKick(LeftForward)0"
	# Add more mappings as needed
}

# Dictionary to store buffer entry times for AnimationPlayer animations
var buffer_entry_times: Dictionary = {
	"Jab(LeftForward)0": 0.4,  # Buffer entry time in seconds
	"CrossPunch(LeftForward)0": 0.7,
	"RegularKick(LeftForward)0": 0.86,
	# Add more entries as needed
	"HookPunch(LeftForward)0": 0.5,  # Add times for heavy attacks
	"RoundhouseKick(LeftForward)0": 0.5,
	"NewAnim/Stabbing": 0.65,
	"NewAnim/StableSwordOutwardSlash": 0.81,
	"NewAnim/StableSwordInwardSlash": 1.12,
	"NewAnim/ThrustSlash": 0.7
	
	
	
	
	
}


# New dictionary for time scales (adjust values as needed for pacing)
var animation_time_scales: Dictionary = {
	"LightAttack1": 1.5,  
	"LightAttack2": 1.5,  
	"LightAttack3": 1.5,  
	"HeavyAttack1": 1.0, 
	"HeavyAttack2": 1.0
}


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

# Inventory
var inventory : Inventory
@onready var inventory_ui: InventoryUI = $"../CanvasLayer/InventoryUI"

func apply_shake():
	shake_strength = randomShakeStrength
	
func random_offset() -> Vector2:
	return Vector2(rng.randf_range(-shake_strength,shake_strength), rng.randf_range(-shake_strength,shake_strength))

func update_animation_state():
	# If currently attacking, keep that state until it finishes.
	if curAnim == ATTACKLight:
		return
	# Set state based on priority: running > walking > idle.
	if PlayerManager.is_running:
		curAnim = RUN
	elif PlayerManager.is_walking:
		curAnim = WALK
	elif PlayerManager.is_idle:
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
	# Add ammo manager
	add_child(ammo_manager)
	ammo_manager.ammo_changed.connect(_on_ammo_changed)
	ammo_manager.magazine_changed.connect(_on_magazine_changed)
	ammo_manager.reload_complete.connect(_on_reload_complete)
	current_weapon = unarmed_weapon  # Set default to unarmed
	# Setup ammo display
	if ammo_display:
		ammo_display.setup(self)
	else:
		print("Error: AmmoDisplay node not found!")
	# Test with pistol
	inventory = Inventory.new()
	inventory_ui.inventory = inventory
	var pistol = load("res://scenes/Weapons/WeaponRes/Pistol.tres")
	var result = inventory.add_item(pistol)
	if result.keys()[0] == false:
		print(result.values()[0])
	 # If current_weapon is already set (e.g., from a default weapon)
	if current_weapon and current_weapon.sound_equip:
		equip_sound = current_weapon.sound_equip
	else:
		equip_sound = null  # Default to null if no weapon or sound
	if buffer_visual:
		buffer_visual.visible = false  # For Sprite3D



func pickup_weapon(new_weapon: WeaponResource):
	if inventory.get_size() == 0:
		print("Inventory Full!")
		return
	else:
		inventory.add_item(new_weapon)
		print(new_weapon.name, " added to inventory.")
		equip_weapon(new_weapon)

# Weapon equipping function
func equip_weapon(new_weapon: WeaponResource) -> void:
	if current_weapon_model:
		weapon_attachment.remove_child(current_weapon_model)
		current_weapon_model.queue_free()
		current_weapon_model = null
	current_weapon = new_weapon
	emit_signal("weapon_changed", current_weapon)
	
	# Update AnimationTree with weapon-specific animations
	print("Equipping weapon: ", new_weapon.name)
	print("Attack animations: ", new_weapon.animation_mapping)
# Update AnimationTree with weapon-specific animations
	for node_name in ATTACK_NODES:  # e.g., "LightAttack1", "LightAttack2"
		var anim_name = new_weapon.animation_mapping.get(node_name, default_attack_animations.get(node_name, ""))
		if ap.has_animation(anim_name):
			ap_tree_2.set("parameters/" + node_name + "/animation", anim_name)
		else:
			print("Warning: Animation '%s' not found for '%s'" % [anim_name, node_name])
	
	# Set hitbox based on weapon state
	if new_weapon.classification == Item.Classification.UNARMED:
		current_hitbox = right_arm_collision  # Use arm hitbox for unarmed
	else:
		if new_weapon.model_scene:
			current_weapon_model = new_weapon.model_scene.instantiate()
			print("Instantiated model: ", current_weapon_model)  # Debug: Is it instantiated?
			weapon_attachment.add_child(current_weapon_model)
			current_weapon_model.rotation_degrees = Vector3(90, 90, 0)  # Adjust rotation to align with hand
			current_weapon_model.position = Vector3(0, 10, 5)  # Fine-tune position if needed
			current_weapon_model.scale = Vector3(20, 20, 20)
			print("Parent after add: ", current_weapon_model.get_parent())  # Debug: Is it attached?
			current_hitbox = current_weapon_model.get_node("Hitbox")
			# Find muzzle position in the weapon model
			muzzle_position = current_weapon_model.get_node("MuzzlePosition") if current_weapon_model.has_node("MuzzlePosition") else null
			if not muzzle_position:
				print("Warning: MuzzlePosition not found in weapon model!")
		# Initialize ammo for ranged weapons
	if new_weapon is Ranged:
		ammo_manager.set_current_weapon(new_weapon)
		# Optional: If it's a new weapon type, you might want to auto-reload here
		if ammo_manager.current_magazine <= 0:
			ammo_manager.reload()
	
	#Make Equip Sound on equip
		# Check and play equip sound
	# Update the equip_sound_stream when equipping a new weapon
	if current_weapon.sound_equip:
		firing_sound.stream = current_weapon.sound_equip  # Assign the AudioStream to the player
		firing_sound.play()  # Play the sound
	else:
		equip_sound = null
	# Connect hitbox signal
	if current_hitbox:
		current_hitbox.body_entered.connect(_on_hitbox_entered)
	
	#if new_weapon.classification != WeaponResource.Classification.UNARMED:
		#if new_weapon.model_scene:
			#current_weapon_model = new_weapon.model_scene.instantiate()
			#weapon_attachment.add_child(current_weapon_model)
	print("Equipped weapon: ", new_weapon.name)

## [method inv_switch_weapons(slot : int)] [param slot]
## [br] Used to switch with weapons within the inventory.
func inv_switch_weapons(slot : int):
	if slot > inventory.get_max_slots():
		print("Not enough slots! ", slot, " is greater than ", inventory.get_max_slots, ".")
		return
	if inventory.get_item(slot) == null:
		print("No weapon in this slot (", slot, ")")
		return
	var new_weapon = inventory.get_item(slot)
	equip_weapon(new_weapon)

func _physics_process(delta):

	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0, ShakeFade * delta)
		# Apply the shake to camera_anchor's position
		var shake_offset = random_offset()  # Get Vector2 offset
		# Map 2D offset to 3D local space (X and Y in camera's local space)
		var local_offset = Vector3(shake_offset.x, shake_offset.y, 0) * 0.01  # Scale down for subtle effect
		camera_anchor.position = default_anchor_offset + camera_anchor.transform.basis * local_offset
	else:
		# Reset to default position when shake is done
		camera_anchor.position = default_anchor_offset
			
	if is_hitstunned:
		velocity = Vector3.ZERO
		return  # Skip the rest of the process function
	
	# Handle ranged weapon input
	if current_weapon is Ranged:
		handle_ranged_weapon_input(delta)
	
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
		PlayerManager.is_walking = false
		PlayerManager.is_running = true
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
		PlayerManager.is_walking    = true
		PlayerManager.is_running    = false
		PlayerManager.can_jump      = false
	else:
		current_speed = SPEED
		PlayerManager.is_walking    = true
		PlayerManager.is_running    = false
		PlayerManager.can_jump      = false
	
	
# If stamina is exhausted, force walking mode (non-running)
		if stamina_component.stamina <= 0:
			current_speed = SPEED
			PlayerManager.is_running = false
			PlayerManager.is_walking = true
	
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
	
	# Trigger buffered attack during recovery
	if current_phase == "recovery" and buffered_attack:
		trigger_buffered_attack()
	#---------------------------------
	# 8) Idle/walking/running detection
	#---------------------------------
	if move_direction.x == 0 and move_direction.z == 0:
		PlayerManager.is_idle     = true
		PlayerManager.is_walking  = false
		PlayerManager.is_running  = false
	else:
		PlayerManager.is_idle = false
	
	#---------------------------------
	# 9) Animations
	#---------------------------------
	
	##MOVE TO OTHER PROCESS YOU SILLY FUCK
# Decrease combo_timer if it’s > 0
	if combo_timer > 0:
		combo_timer -= delta
		if combo_timer <= 0:
			reset_combo()
#
		##Reset Combo States after Timer Clears
	#if combo_index == 0:
		#in_light_combo = false
		#in_heavy_combo = false
		#hitbox_active = false
		#print("Combos Reset!")
	
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
			
	# Switching Weapons from inventory
	if Input.is_action_just_pressed("weapon_slot_1"):
		if inventory.get_item(0) != null:
			print("Weapon Slot 1 is empty")
		inv_switch_weapons(0)
	
	if Input.is_action_just_pressed("weapon_slot_2"):
		if inventory.get_item(1) != null:
			print("Weapon Slot 2 is empty")
		inv_switch_weapons(1)
	
	if Input.is_action_just_pressed("fists"):
		equip_weapon(unarmed_weapon)

	# Inventory UI
	if Input.is_action_just_pressed("inventory"):
		if !inventory_ui.visible:
			inventory_ui.open_inventory()
		else:
			inventory_ui.close_inventory()

func _on_hitbox_entered(body):
	if hitbox_active and body.is_in_group("enemies"):
		var attack_instance = Attack.new(current_weapon.damage, 0.0, 0.0, 0.0, 0.0, global_position)
		emit_signal("player_attacking", attack_instance, true, current_weapon)
		print("Hitbox hit enemy, dealing damage: ", current_weapon.damage)
		punch_sound.play()
		hitbox_active = false
		apply_shake()


# Reset the combo once the timer expires or the max hit is reached
func reset_combo() -> void:
	combo_index = 0
	current_attack_type = AttackType.NONE
	is_attacking = false
	print("Combo reset")
	
	
	
	

#
### -------------------------------
### Buffer Window Functions
### (These will be called from the animation timeline via Call Method tracks)
### -------------------------------
#func open_buffer_window() -> void:
	#can_buffer_attack = true
	#print("Buffer window opened - can_buffer_attack: ", can_buffer_attack)
	## If the input was already buffered, immediately chain the next attack
	#if buffered_attack:
		#print("Attack finished, popping next queue")
		#attack_finished()
#
#
#func close_buffer_window() -> void:
	#can_buffer_attack = false
	#print("Buffer window closed - can_buffer_attack: ", can_buffer_attack)
	## Optionally, if no input was buffered at this point, you could reset here
	## if not buffered_attack:
	##     reset_combo()
#
#
## Check for buffered attack (called at 1.5s)
#func check_buffered_attack() -> void:
	#if buffered_attack:
		#trigger_buffered_attack()


# -------------------------------
# Input & Timer Handling
# -------------------------------
func _input(event: InputEvent) -> void:
	
	if Input.is_action_just_pressed("AnimationInput"):
		ap_tree_2.set("parameters/NewAnimation/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		print("Playing NewAnim/new_animation")
		# Aim toggle handling
	if event.is_action_pressed("aim_toggle") and current_weapon is Ranged:
		_aim_pcam.set_third_person_rotation_degrees(_player_pcam.get_third_person_rotation_degrees())
		_aim_pcam.set_priority(30)
		_player_pcam.set_priority(0)
		is_aiming = true
		print("Aim mode on")
	elif event.is_action_released("aim_toggle"):
		_player_pcam.set_third_person_rotation_degrees(_aim_pcam.get_third_person_rotation_degrees())
		_aim_pcam.set_priority(0)
		_player_pcam.set_priority(30)
		is_aiming = false
		print("Aim mode off")
		
	# Light attack input
	if Input.is_action_just_pressed("light_attack"):
		if is_aiming and current_weapon is Ranged and can_fire and not is_reloading:
			fire_weapon()
		elif can_buffer_attack and is_attacking and current_attack_type == AttackType.LIGHT:
			buffered_attack = true
			print("Buffered light attack")
		elif not is_attacking:
			start_attack(AttackType.LIGHT, true)
			combo_timer = MAX_COMBO_WINDOW  # Start the combo timer for new attacks

	elif Input.is_action_just_pressed("heavy_attack"):
		if can_buffer_attack and is_attacking and current_attack_type == AttackType.HEAVY:
			buffered_attack = true
			print("Buffered heavy attack")
		elif not is_attacking:
			start_attack(AttackType.HEAVY, true)
			combo_timer = MAX_COMBO_WINDOW  # Start the combo timer for new attacks

	if Input.is_action_just_pressed("Shake"):
		apply_shake()
		print("Shake Screen NOWWWW")
			
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
	apply_shake()



func animation_updates(current_speed, move_direction):
	if PlayerManager.is_idle:
		ap.play("Idle(1)0")
	elif PlayerManager.is_walking:
		ap.play("Walking(2)0")
	elif PlayerManager.is_running:
		ap.play("Running(1)0")
		

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
	print("Blocking!")	# Remove when animation exists
	is_blocking = true
	# Is player still blocking?
	
	# End Block


func _on_block_cooldown_timeout() -> void:
	blocking_on_cooldown = false

func current_action() -> String:
	if PlayerManager.is_blocking:
		return "blocking"
	elif PlayerManager.is_crouched:
		return "crouched"
	elif PlayerManager.is_dodging:
		return "dodging"
	elif PlayerManager.is_running:
		return "running"
	elif PlayerManager.is_walking:
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

func activate_hitbox() -> void:
	hitbox_active = true
	print("Hitbox activated")

func deactivate_hitbox() -> void:
	hitbox_active = false
	print("Hitbox deactivated")

func handle_ranged_weapon_input(delta: float) -> void:
	# Update fire cooldown timer
	if fire_cooldown_timer > 0:
		fire_cooldown_timer -= delta
		if fire_cooldown_timer <= 0:
			can_fire = true
	
	## Handle weapon firing
	#if Input.is_action_pressed("fire") and can_fire and current_weapon is Ranged and not is_reloading:
		#fire_weapon()
	#
	# Handle reloading
	if Input.is_action_just_pressed("reload") and current_weapon is Ranged and not is_reloading:
		start_reload()
	
	# Handle aiming
	if Input.is_action_pressed("aim_toggle") and current_weapon is Ranged:
		is_aiming = true
	else:
		is_aiming = false


func fire_weapon() -> void:
	# Check if we have ammo
	if not ammo_manager.use_ammo(1):
		# Play empty sound
		if current_weapon.sound_empty:
			firing_sound.stream = current_weapon.sound_empty
			firing_sound.play()
		return
	
	# Set cooldown
	can_fire = false
	fire_cooldown_timer = 1.0 / current_weapon.fire_rate
	
	# Play firing sound
	if current_weapon.sound_fire:
		firing_sound.stream = current_weapon.sound_fire
		firing_sound.play()
	
	# Get the camera for raycasting
	var camera = get_viewport().get_camera_3d()
	if not camera:
		print("Error: No active camera found!")
		return
	
	# Raycast from screen center (crosshair) to find aim point
	var screen_center = get_viewport().get_visible_rect().size / 2
	var ray_origin = camera.project_ray_origin(screen_center)
	var ray_direction = camera.project_ray_normal(screen_center)
	   
	var space_state = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = ray_origin
	ray_query.to = ray_origin + ray_direction * 1000  # Ray length, adjust if needed
	var result = space_state.intersect_ray(ray_query)
	
	var aim_point
	if result:
		aim_point = result.position
	else:
		aim_point = ray_origin + ray_direction * 1000
		 
	# Calculate direction from muzzle to aim point
	var base_direction
	if muzzle_position:
		base_direction = (aim_point - muzzle_position.global_position).normalized()
	else:
		base_direction = (aim_point - weapon_attachment.global_position).normalized()
  
# Spawn projectile(s)
	var projectile_count = current_weapon.projectile_count
	for i in range(projectile_count):
		# Create projectile instance
		var projectile = current_weapon.projectile_scene.instantiate()
		projectile_container.add_child(projectile)
		
	# Set projectile position to muzzle or fallback to weapon attachment
		if muzzle_position:
			projectile.global_position = muzzle_position.global_position
		else:
			print("Warning: MuzzlePosition is null, using weapon attachment position!")
			projectile.global_position = weapon_attachment.global_position
 
# Calculate projectile direction with spread
		var direction = base_direction
		
		 # Add spread if applicable
		if current_weapon.spread > 0.0 or i > 0:
			var rand_spread_x = randf_range(-current_weapon.spread, current_weapon.spread)
			var rand_spread_y = randf_range(-current_weapon.spread, current_weapon.spread)
			var rot_basis = Basis(Vector3.UP, deg_to_rad(rand_spread_y)) * Basis(Vector3.RIGHT, deg_to_rad(rand_spread_x))
			direction = rot_basis * direction
		
		# Set up the projectile
		projectile.setup(
			current_weapon.damage,
			current_weapon.projectile_speed,
			direction,
			global_position,
			self
			)
			
	# Optional: Spawn muzzle flash effect
	if current_weapon.muzzle_flash_scene:
		var muzzle_flash = current_weapon.muzzle_flash_scene.instantiate()
		if muzzle_position:
			muzzle_position.add_child(muzzle_flash)
		else:
			weapon_attachment.add_child(muzzle_flash)

func start_reload() -> void:
	if is_reloading or ammo_manager.current_magazine >= current_weapon.magazine_size:
		return
	
	is_reloading = true
	
	# Play reload animation
	# You'll need to add this to your AnimationTree
	ap_tree_2.set("parameters/Reload/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
	# Play reload sound
	if current_weapon.sound_reload:
		firing_sound.stream = current_weapon.sound_reload
		firing_sound.play()
	
	# Set a timer for reload time
	await get_tree().create_timer(current_weapon.reload_time).timeout
	
	# Complete reload
	ammo_manager.reload()
	is_reloading = false

# Signal callbacks
func _on_ammo_changed(type, current, max_ammo) -> void:
	# You'll need to create a UI element to display ammo
	# For example: ammo_display.text = str(current) + "/" + str(max_ammo)
	pass

func _on_magazine_changed(current, max_size) -> void:
	# You'll need to create a UI element to display magazine ammo
	# For example: magazine_display.text = str(current) + "/" + str(max_size)
	pass

func _on_reload_complete() -> void:
	# Called when reload is finished
	pass


# Attack Functions
func start_attack(attack_type: int, new_combo: bool = true) -> void:
	if is_attacking and not new_combo:
		return
	is_attacking = true
	
	
	# Update combo index
	if new_combo:
		combo_index = 1
	else:
		combo_index = min(combo_index + 1, MAX_LIGHT_COMBO_HITS if attack_type == AttackType.LIGHT else MAX_HEAVY_COMBO_HITS)
		
		
	# Determine the OneShot node name
	var node_name = ("LightAttack" if attack_type == AttackType.LIGHT else "HeavyAttack") + str(combo_index)
		# Get animation and node details from weapon
	# Trigger the attack animation via AnimationTree
	if node_name in ATTACK_NODES:
		ap_tree_2.set("parameters/" + node_name + "/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		current_animation = node_name
		current_attack_type = attack_type
		hitbox_active = true  # Activate hitbox when attack starts
		print("Started attack: ", node_name)
	else:
		print("Error: Invalid attack node '%s'" % node_name)	
	
	

	


# --- Animation Phase Functions (Called from Timeline) ---

func start_startup() -> void:
	current_phase = "startup"
	is_attacking = true
	print("Startup phase started")


func start_action() -> void:
	current_phase = "action"
	open_buffer_window()  # Open buffer window during action phase
	hitbox_active = true
	print("Action phase started")

	
func start_recovery() -> void:
	current_phase = "recovery"
	close_buffer_window()
	if buffered_attack:
			trigger_buffered_attack()
	print("Recovery phase started")
	
	
func animation_finished() -> void:
	current_phase = "none"
	if not buffered_attack:
		reset_combo()
	is_attacking = false
	hitbox_active = false
	print("Animation finished")
	
	
	
# --- Buffer Entry Time Setting (Called from Timeline) ---
func set_buffer_entry_time(anim_name: String, time: float) -> void:
	# Store the current playback position as the buffer entry time for this animation
	buffer_entry_times[anim_name] = time
	print("Buffer time set for animation '%s' to %s" % [anim_name, time])





func open_buffer_window() -> void:
	can_buffer_attack = true
	print("Buffer window opened")
	if buffer_visual:
		buffer_visual.visible = true  # Turn on the visual for Sprite3D

func close_buffer_window() -> void:
	can_buffer_attack = false
	if buffer_visual:
		buffer_visual.visible = false  # Turn off the visual for Sprite3D
	print("Buffer window closed")




func get_buffer_entry_time(anim_name: String) -> float:
	var current_anim = ap_tree_2.get("parameters/" + anim_name + "/animation")
	if buffer_entry_times.has(current_anim):
		return buffer_entry_times[current_anim]
	print("No buffer entry time set for ", anim_name, " (mapped to ", current_anim, "), defaulting to 0.0")
	return 0.0  # Default to start if not set



# Helper function to get the one-shot node path based on attack type and index
func get_one_shot_path(attack_type: int, index: int) -> String:
	if attack_type == AttackType.LIGHT:
		return "parameters/LightAttack" + str(index) 
	elif attack_type == AttackType.HEAVY:
		return "parameters/HeavyAttack" + str(index) 
	return ""


	#Play the appropriate attack animation
func play_attack_animation(attack_type: int) -> void:
	if ap_tree_2:
		if attack_type == AttackType.LIGHT:
			match combo_index:
				1:
					print("Playing LightAttack1 animation")
					ap_tree_2.set("parameters/LightAttack1/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
				2:
					print("Playing LightAttack2 animation")
					ap_tree_2.set("parameters/LightAttack2/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
				3:
					print("Playing LightAttack3 animation")
					ap_tree_2.set("parameters/LightAttack3/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		elif attack_type == AttackType.HEAVY:
			match combo_index:
				1:
					print("Playing HeavyAttack1 animation")
					ap_tree_2.set("parameters/HeavyAttack1/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
				2:
					print("Playing HeavyAttack2 animation")
					ap_tree_2.set("parameters/HeavyAttack2/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	else:
		print("ERROR: AnimationTree2 not found, cannot play attack animation!")


# Called when an attack animation finishes (via AnimationTree call method track or signal)
func attack_finished() -> void:
	if was_buffered_canceled:
		was_buffered_canceled = false
		return

	


func trigger_buffered_attack() -> void:
	if not buffered_attack or current_attack_type == AttackType.NONE:
		return
	buffered_attack = false
	start_attack(current_attack_type, false)  # Continue combo
	print("Triggered buffered attack")
	
	## Cancel the current animation
	#var current_anim = ("LightAttack" if current_attack_type == AttackType.LIGHT else "HeavyAttack") + str(combo_index)
	#var current_one_shot_path = "parameters/" + current_anim + "/request"
	#ap_tree_2.set(current_one_shot_path, AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	#
	## Increment combo index
	#combo_index = clamp(combo_index + 1, 1, MAX_LIGHT_COMBO_HITS if current_attack_type == AttackType.LIGHT else MAX_HEAVY_COMBO_HITS)
	#
	## Determine next animation
	#var next_anim = ("LightAttack" if current_attack_type == AttackType.LIGHT else "HeavyAttack") + str(combo_index)
	#
	## Get the buffer entry time
	#var buffer_entry_time = get_buffer_entry_time(next_anim)
	#
		## Set the seek time for the TimeSeek node
	#var time_seek_node = "TimeSeek_" + next_anim
	#var seek_path = "parameters/" + time_seek_node + "/seek_request"
	#ap_tree_2.set(seek_path, buffer_entry_time)
	#
	## Set the time scale for the TimeScale node
	#var time_scale_node = "TimeScale_" + next_anim
	#var scale_path = "parameters/" + time_scale_node + "/scale"
	#var time_scale = animation_time_scales.get(next_anim, 1.0)  # Default to 1.0 if not found
	#ap_tree_2.set(scale_path, time_scale)
	#
	#
	## Fire the next animation and seek to the buffer entry time
	#var oneshot_path = "parameters/" + next_anim + "/request"
	#ap_tree_2.set(oneshot_path, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	#
	#
	## Update state
	#current_animation = next_anim  # Update the current animation
	#buffered_attack = false
	#print("Buffered attack triggered: ", next_anim, " at time ", buffer_entry_time, " with time scale ", time_scale)
#
	#
	#
	
	
	
	#if buffered_attack and current_attack_type != AttackType.NONE:
		#start_attack(current_attack_type)
		#buffered_attack = false
		#print("Triggered buffered attack: ", get_current_attack_type())


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
func print_debug_statements(content: Array[String] = []):
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
				print("Can_fire : ", can_fire)
			"animation":
				print("can buffer attack: ", can_buffer_attack)
				print("buffered_attack: ", buffered_attack)
				print("States: is_walking: ", PlayerManager.is_walking)
				print("States: is_running: ", PlayerManager.is_running)
				print("States: can_jump: ", PlayerManager.can_jump)
				print("States: Is_In_Range: ", is_in_range)
				print("States: combat: ", is_in_combat)
# Start an attack and play its animation
