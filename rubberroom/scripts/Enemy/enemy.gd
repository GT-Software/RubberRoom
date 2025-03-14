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

# Export variables

@export var SPEED = 3.0
@export var RUN_SPEED = 60.0
@export var TURN_SPEED = 2.0
@export var current_speed : float

# Boolean variables
var is_locked_on : bool = false
var is_spotted : bool = false
var is_chasing : bool = false
var is_in_range : bool = false
var is_alive : bool = true
var on_attack_cooldown : bool = false
var rotate_self : bool = true

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

var combo_index = 0
var combo_timer = 0.0
const MAX_COMBO_WINDOW = 1.35 # 400 ms window for the next attack

func _ready():
	current_speed = SPEED
	is_chasing = false
	health_component = HealthComponent.new()
	detection_area.connect('is_detected', alert)
	melee_range.connect('range', on_in_melee_range)


func _physics_process(delta: float):
	handle_animations()
	#Note From Ryan: This is just here so that I can make it work for now, if we need to 
	#give this thing a new home after its fine. But for now, this is how it will work
	print("Enemy States: is_idle: ", is_idle)
	print("Enemy States: is_walking: ", is_walking)
	print("Enemy States: is_running: ", is_running)
	print("Enemy States: can_jump: ", can_jump)
	print("Enemy States: Player Spotted: ", player_spotted)
	print("Enemy States: Is_In_Range: ", is_in_range)
	
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
		
	velocity.y -= gravity * delta
	
	if rotate_self:
		if rotate_node != null:
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
	var random_position : Vector3
	
	# Choose a random position relative to the player, so it does not seem like the enemy is actually chasing the player.
	random_position = Vector3(randf_range(player.position.x - 40, player.global_position.x + 40), position.y, randf_range(player.position.z - 40, player.global_position.z + 40))
	# Clamps the random position to the boundaries of the world (currently 100, 100 subtract by 5 for wiggle room)
	random_position.x = clamp(random_position.x, -40, 40)
	random_position.z = clamp(random_position.z, -40, 40)
	
	return random_position



func handle_animations():
	match curAnim:
		IDLE:
			anim_tree.set("parameters/Movement/transition_request" , "Idle")
		WALK:
			anim_tree.set("parameters/Movement/transition_request" , "Walking")
		RUN:
			anim_tree.set("parameters/Movement/transition_request" , "Running")
		ATTACK:
			anim_tree.set("parameters/Movement/transition_request" , "ComboBreaker")
			

func alert(new_target):
	target = new_target


func attack():
	var attack : Attack = Attack.new()
	curAnim = WALK
	emit_signal("attacking", attack)

func take_damage(attack : Attack):
	health_component.damage(attack)
	
func on_in_melee_range(in_range : bool):
	is_in_range = in_range

# Update the current path and velocity
func update_nav_agent():
	var next_location = nav_agent.get_next_path_position()
	var current_location = global_transform.origin
	var new_velocity = (next_location - current_location).normalized() * current_speed
	
	# Sets the velocity value for the nav_agent to calculate a safe direction (see _on_navigation_agent_3d_velocity_computed
	nav_agent.set_velocity(new_velocity)

# Updates the Navigation Agent's targetted vector position
func update_target_location(target_location) -> void:
	print(self.name + ": Updating enemy target location...")
	nav_agent.target_position = target_location

# If the enemy has reached its target, stop moving
func _on_navigation_agent_3d_target_reached() -> void:
	print(self.name + ": Target reached.")
	nav_agent.set_velocity(Vector3.ZERO)

# Set velocity to a safe velocity for moving around enemies (must adjust)
func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	velocity = velocity.move_toward(safe_velocity, .25)
	move_and_slide()
	
func update_lock_on_status():
	#Once "Locked On" Signal Received Via Player Hitting Middle Mouse
	#Turn is_locked_on to true
	#same "Locked On Signal Should change state for player as well
	pass


func _on_player_attacking(attack: Attack, in_range : bool):
	take_damage(attack)
	print("Received player_attacking signal with: ", attack, ", in_range: ", in_range)
	enemy_health_bar._on_health_changed(health_component.health)
	print("Current Enemy Health: ", health_component.get_health())
		


func _on_enemy_melee_range_exited(body):
	pass # Replace with function body.
