extends Node3D
class_name StunComponent

@export var MIN_STUN = 0.0
@export var MAX_STUN = 10.0
var stun: float

func _ready():
	stun = MIN_STUN
	
func damage(attack: Attack):
	stun -= attack.stun_damage
	
	if stun <= 0:
		get_parent().queue_free()
		#Create stunned effect and apply to character
