extends Node3D
class_name StunComponent


@export var MAX_STUN = 10.0 : set = set_max_stun, get = get_max_stun
var stun : float : set = set_stun, get = get_stun


func _init(init_stun = 10.0):
	MAX_STUN = init_stun
	stun = init_stun
	
####### SETTERS #######
func set_max_stun(new_max : float):
	MAX_STUN= new_max

func set_stun(new_stun : float):
	stun = new_stun

func stun_drain():
	stun -= 0.05

####### GETTERS ########
func get_max_stun() -> float:
	return MAX_STUN

func get_stun() -> float:
	return stun

func heal():
	stun += 2.5

func damage(attack: Attack):
	stun -= attack.stun_damage
