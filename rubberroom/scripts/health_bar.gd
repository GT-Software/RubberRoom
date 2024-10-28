extends ProgressBar

@onready var health_damage_bar = %HealthDamageBar
@onready var timer = $Timer

func _on_health_changed(new_health):
	_set_health(new_health)

func _set_health(new_health):
	var previous_health = value  # 'value' is the ProgressBar's current value
	value = min(max_value, new_health)
	if value <= previous_health:
		timer.start()
	else:
		health_damage_bar.value = value

func init_health(health_component):
	max_value = health_component.MAX_HEALTH
	value = health_component.health
	max_value = health_component.MAX_HEALTH
	value = health_component.health

func _on_timer_timeout():
	health_damage_bar.value = value
