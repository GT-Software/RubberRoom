extends ProgressBar

@onready var stun_damage_bar = $StunDamageBar
@onready var timer = $Timer

func _on_stun_changed(new_stun):
	_set_stun(new_stun)

func _set_stun(new_stun):
	var previous_stun = value  # 'value' is the ProgressBar's current value
	value = min(max_value, new_stun)
	if value <= previous_stun:
		timer.start()
	else:
		stun_damage_bar.value = value

func init_stun(stun_component):
	max_value = stun_component.MAX_STUN
	value = stun_component.stun
	stun_damage_bar.max_value = stun_component.MAX_STUN
	stun_damage_bar.value = stun_component.stun

func _on_timer_timeout():
	stun_damage_bar.value = value
