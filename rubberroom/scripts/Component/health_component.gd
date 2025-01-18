extends Node3D
class_name HealthComponent

@export var MAX_HEALTH = 10.0 : set = set_max_health, get = get_max_health
var health : float : set = set_health, get = get_health



func _init(init_health = 10.0):
	MAX_HEALTH = init_health
	health = init_health
	
####### SETTERS #######
func set_max_health(new_max : float):
	MAX_HEALTH += 2.5
	

func set_health(new_health : float):
	health = new_health
	
func health_drain():
	health -= 0.05


####### GETTERS ########
func get_max_health() -> float:
	return MAX_HEALTH

func get_health() -> float:
	return health

func heal():
	health += 2.5

func damage(attack: Attack):
	health -= attack.health_damage
