extends Node3D
class_name HealthComponent

@export var MAX_HEALTH = 10.0
var health: float

func _init(init_health = 10.0):
	health = init_health
	

func heal():
	health += 2.5

func damage(attack: Attack):
	health -= attack.health_damage
	
	if health <= 0:
		get_parent().queue_free()
