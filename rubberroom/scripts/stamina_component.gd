extends Node3D
class_name StaminaComponent


@export var MAX_STAMINA = 10.0
var stamina: float

func _ready():
	stamina = MAX_STAMINA
	
func damage(attack: Attack):
	stamina -= attack.stamina_damage
	
	if stamina <= 0:
		get_parent().queue_free()
