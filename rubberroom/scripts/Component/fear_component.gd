extends Node3D
class_name FearComponent

@export var MAX_FEAR = 10.0
var fear: float

func _init(init_fear = 10.0):
	fear = init_fear
	

func fear_heal():
	fear += 2.5

func damage(attack: Attack):
	fear -= attack.fear_damage
	
	if fear <= 0:
		pass
		#Fearful effect
