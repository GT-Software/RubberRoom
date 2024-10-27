extends Area3D
@onready var player = %Player



func _on_heal_entered(body):
	print("HealBox Enter")
	player.health_component.heal()
	print(player.health_component.health)
	player.health_bar._on_health_changed(player.health_component.health)
	


func _on_hurt_entered(body):
	print("HurtBox Enter, Taking Damage")
	var attack = Attack.new()
	attack.health_damage = 2.0
	player.health_component.damage(attack)
	print(player.health_component.health)
	player.health_bar._on_health_changed(player.health_component.health)
	
	
	


func _on_body_exited(body):
	print("HealBox Exit")
