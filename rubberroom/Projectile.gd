extends Area3D
class_name Projectile

var damage: float = 1.0
var speed: float = 30.0
var direction: Vector3 = Vector3.FORWARD
var shooter_position: Vector3 = Vector3.ZERO
var lifetime: float = 5.0
var shooter = null  # Reference to who shot this projectile

@onready var timer = $Timer

signal hit_something(body, position)

func _ready():
	var timer = get_node_or_null("Timer")
	if not timer:
		timer = Timer.new()
		add_child(timer)
		timer.name = "Timer"
		timer.wait_time = lifetime
		timer.one_shot = true
		timer.timeout.connect(_on_lifetime_expired)
		timer.start()
	# Connect body entered signal
	body_entered.connect(_on_body_entered)

func _physics_process(delta):
	# Move in the direction at the set speed
	global_position += direction * speed * delta

func _on_body_entered(body):
	# Ignore the shooter
	if body == shooter:
		return
		
	# Process hit for enemies
	if body.is_in_group("enemies") and shooter.is_in_group("player"):
		# Create an Attack object similar to your melee system
		var attack = Attack.new(damage, 0.0, 0.0, 0.0, 0.0, shooter_position)
		
		# If the enemy has a method to handle attacks, call it
		if body.has_method("take_damage"):
			body.take_damage(attack)
		
		# Emit hit signal
		hit_something.emit(body, global_position)
		
		# Destroy projectile
		queue_free()
	
	# Process hit for player
	elif body.is_in_group("player") and shooter.is_in_group("enemies"):
		# Create an Attack object
		var attack = Attack.new(damage, 0.0, 0.0, 0.0, 0.0, shooter_position)
		
		# If player has a method to handle attacks
		if body.has_method("_on_enemy_attacking"):
			body._on_enemy_attacking(attack)
		
		# Emit hit signal
		hit_something.emit(body, global_position)
		
		# Destroy projectile
		queue_free()
	
	# Hit environment/walls
	elif not body.is_in_group("player") and not body.is_in_group("enemies"):
		# Emit hit signal for effects
		hit_something.emit(body, global_position)
		
		# Destroy projectile
		queue_free()

func _on_lifetime_expired():
	queue_free()

func setup(new_damage: float, new_speed: float, new_direction: Vector3, new_shooter_position: Vector3, new_shooter):
	damage = new_damage
	speed = new_speed
	direction = new_direction.normalized()
	shooter_position = new_shooter_position
	shooter = new_shooter
