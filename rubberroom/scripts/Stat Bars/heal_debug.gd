extends Area3D




func _on_heal_entered(body):
	if body.is_in_group("player"):
		print("HealBox Enter")
		body.health_component.heal()
		print(body.health_component.health)
		body.health_bar._on_health_changed(body.health_component.health)
	


func _on_hurt_entered(body):
	if body.is_in_group("player"):
		print("HurtBox Enter, Taking Damage")
		var attack = Attack.new()
		attack.health_damage = 2.0
		body.health_component.damage(attack)
		print(body.health_component.health)
		body.health_bar._on_health_changed(body.health_component.health)
	
	
	


func _on_body_exited(body):
	print("HealBox Exit")
