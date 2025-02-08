extends Node3D
class_name StaminaComponent
@onready var player = %Player

@export var MAX_STAMINA = 10.0 : set = set_max_stamina, get = get_max_stamina
var stamina : float : set = set_stamina, get = get_stamina


func _init(init_stamina = 10.0):
	MAX_STAMINA = init_stamina
	stamina = init_stamina
	
####### SETTERS #######
func set_max_stamina(new_max : float):
	MAX_STAMINA = new_max

func set_stamina(new_stamina : float):
	stamina = new_stamina
	
func stamina_drain(drain = 0.1):
	stamina -= drain


####### GETTERS ########
func get_max_stamina() -> float:
	return MAX_STAMINA

func get_stamina() -> float:
	return stamina

func heal():
	stamina += 2.5

func damage(attack: Attack):
	stamina -= attack.stamina_damage
