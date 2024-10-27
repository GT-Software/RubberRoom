extends Area3D


func _on_hurt_entered(body):
	if body.is_in_group("player"):
		print("FearHurtBox Enter, Taking Fear Damage")
		var attack = Attack.new()
		attack.fear_damage = 2.5
		body.fear_component.damage(attack)
		print(body.fear_component.fear)
		body.fear_bar._on_fear_changed(body.fear_component.fear)
	
	


func _on_heal_entered(body):
	if body.is_in_group("player"):
		print("StunHealBox Enter")
		body.fear_component.fear_heal()
		print(body.fear_component.fear)
		body.fear_bar._on_fear_changed(body.fear_component.fear)
