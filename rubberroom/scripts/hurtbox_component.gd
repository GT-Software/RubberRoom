extends Area3D
@onready var player = %Player

#@export var health_component: HealthComponent

#func damage(attack: Attack):
	#if health_component:
		#health_component.damage(attack)


func _on_body_entered(body):
	print("HurtBox Enter, Taking Damage")
	var attack = Attack.new()
	attack.health_damage = 2.0
	player.health_component.damage(attack)
	print(player.health_component.health)
	player.health_bar._on_health_changed(player.health_component.health)
	
	
	


func _on_body_exited(body):
	print("HurtBox Exit")
