extends Area3D
@onready var player: CharacterBody3D = %Player

func _on_hurt_entered(body):
	print("FearHurtBox Enter, Taking Fear Damage")
	var attack = Attack.new()
	attack.fear_damage = 2.5
	player.fear_component.damage(attack)
	print(player.fear_component.fear)
	player.fear_bar._on_fear_changed(player.fear_component.fear)
	
	


func _on_heal_entered(body):
	print("StunHealBox Enter")
	player.fear_component.fear_heal()
	print(player.fear_component.fear)
	player.fear_bar._on_fear_changed(player.fear_component.fear)
