extends Area3D
@onready var player = %Player


func _on_body_entered(body):
	print("StunHealBox Enter")
	player.stun_component.stun_heal()
	print(player.stun_component.stun)
	player.stun_bar._on_stun_changed(player.stun_component.stun)
