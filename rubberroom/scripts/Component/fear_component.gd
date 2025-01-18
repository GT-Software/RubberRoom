extends Node3D
class_name FearComponent

@export var MAX_FEAR = 10.0 : set = set_max_fear, get = get_max_fear
var fear : float : set = set_fear, get = get_fear



func _init(init_fear = 10.0):
	MAX_FEAR = init_fear
	fear = init_fear
	
####### SETTERS #######
func set_max_fear(new_max : float):
	MAX_FEAR = new_max

func set_fear(new_fear : float):
	fear = new_fear

func fear_drain():
	fear -= 0.05

####### GETTERS ########
func get_max_fear() -> float:
	return MAX_FEAR

func get_fear() -> float:
	return fear

func heal():
	fear += 2.5

func damage(attack: Attack):
	fear -= attack.fear_damage
