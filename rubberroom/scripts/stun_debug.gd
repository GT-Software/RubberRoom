extends Area3D
@onready var player = %Player


func _on_body_exited(body):
	print("HurtBox Exit")


func _on_heal_entered(body):
	print("StunHealBox Enter")
	player.stun_component.stun_heal()
	print(player.stun_component.stun)
	player.stun_bar._on_stun_changed(player.stun_component.stun)


func _on_hurt_entered(body):
	print("StunHurtBox Enter, Taking Stun Damage")
	var attack = Attack.new()
	attack.stun_damage = 2.5
	player.stun_component.damage(attack)
	print(player.stun_component.stun)
	player.stun_bar._on_stun_changed(player.stun_component.stun)
