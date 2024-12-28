extends Node3D
class_name StunComponent

@export var MAX_STUN = 10.0
var stun: float

func _init(init_stun = 10.0):
	stun = init_stun
	

func stun_heal():
	stun += 2.5

func damage(attack: Attack):
	stun -= attack.stun_damage
	
	
	if stun <= 0:
		pass
		#Create stunned effect and apply to character
