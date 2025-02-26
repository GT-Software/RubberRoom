extends ProgressBar

@onready var stamina_damage_bar = $StaminaDamageBar
@onready var timer = $StaminaDamageBar/Timer

func _on_stamina_changed(new_stamina):
	_set_stamina(new_stamina)
	#print("Stamina left ", self.value)

func _set_stamina(new_stamina):
	var previous_stamina = value  # 'value' is the ProgressBar's current value
	value = min(max_value, new_stamina)
	if value <= previous_stamina:
		timer.start()
	else:
		stamina_damage_bar.value = value

func init_stamina(stamina_component):
	max_value = stamina_component.MAX_STAMINA
	value = stamina_component.stamina
	max_value = stamina_component.MAX_STAMINA
	value = stamina_component.stamina

func _on_timer_timeout():
	stamina_damage_bar.value = value
