extends Area3D
@onready var player = %Player


func _on_hurt_entered(body):
	print("StaminaHurtBox Enter, Taking Stamina Damage")
	var attack = Attack.new()
	attack.stamina_damage = 2.5
	player.stamina_component.damage(attack)
	print(player.stamina_component.stamina)
	player.stamina_bar._on_stamina_changed(player.stamina_component.stamina)
	
	


func _on_heal_entered(body):
	print("StunHealBox Enter")
	player.stamina_component.stamina_heal()
	print(player.stamina_component.stamina)
	player.stamina_bar._on_stamina_changed(player.stamina_component.stamina)




func _on_body_exited(body):
	print("HurtBox Exit")
