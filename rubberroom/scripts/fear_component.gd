extends Node3D
class_name FearComponent

@export var MIN_FEAR = 0.0
@export var MAX_FEAR = 10.0
var fear: float

func _ready():
	fear = MIN_FEAR
	
func damage(attack: Attack):
	fear -= attack.fear_damage
	
	if fear <= 0:
		get_parent().queue_free()
		#Apply whatever we decide for fear/sanity
