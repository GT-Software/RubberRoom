extends Area3D


func _on_hurt_entered(body):
	if body.is_in_group("player"):
		print("StaminaHurtBox Enter, Taking Stamina Damage")
		var attack = Attack.new()
		attack.stamina_damage = 2.5
		body.stamina_component.damage(attack)
		print(body.stamina_component.stamina)
		body.stamina_bar._on_stamina_changed(body.stamina_component.stamina)
	
	


func _on_heal_entered(body):
	if body.is_in_group("player"):
		print("StunHealBox Enter")
		body.stamina_component.stamina_heal()
		print(body.stamina_component.stamina)
		body.stamina_bar._on_stamina_changed(body.stamina_component.stamina)




func _on_body_exited(body):
	print("HurtBox Exit")
