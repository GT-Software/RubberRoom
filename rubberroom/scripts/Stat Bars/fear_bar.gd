extends ProgressBar

@onready var fear_damage_bar = $FearDamageBar
@onready var timer = $FearDamageBar/Timer


func _on_fear_changed(new_fear):
	_set_fear(new_fear)

func _set_fear(new_fear):
	var previous_fear = value  # 'value' is the ProgressBar's current value
	value = min(max_value, new_fear)
	if value <= previous_fear:
		timer.start()
	else:
		fear_damage_bar.value = value

func init_fear(fear_component):
	max_value = fear_component.MAX_FEAR
	value = fear_component.fear
	max_value = fear_component.MAX_FEAR
	value = fear_component.fear

func _on_timer_timeout():
	fear_damage_bar.value = value
