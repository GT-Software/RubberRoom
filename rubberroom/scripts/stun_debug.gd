extends Area3D



func _on_body_exited(body):
	print("HurtBox Exit")


func _on_heal_entered(body):
	if body.is_in_group("player"):
		print("StunHealBox Enter")
		body.stun_component.stun_heal()
		print(body.stun_component.stun)
		body.stun_bar._on_stun_changed(body.stun_component.stun)


func _on_hurt_entered(body):
	if body.is_in_group("player"):
		print("StunHurtBox Enter, Taking Stun Damage")
		var attack = Attack.new()
		attack.stun_damage = 2.5
		body.stun_component.damage(attack)
		print(body.stun_component.stun)
		body.stun_bar._on_stun_changed(body.stun_component.stun)
