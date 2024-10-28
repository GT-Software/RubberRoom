extends Node3D
class_name StaminaComponent
@onready var player = %Player

@export var MAX_STAMINA = 10.0
var stamina: float

func _init(init_stamina = 10.0):
	stamina = init_stamina
	
func stamina_drain():
	stamina -= 0.1

func stamina_heal():
	stamina += 2.5

func damage(attack: Attack):
	stamina -= attack.stamina_damage
	
	
	if stamina <= 0:
		pass
		#Create tired effect and apply to character
