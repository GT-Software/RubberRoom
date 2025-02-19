extends CollisionObject3D
class_name Interactable


##For convinence i will put all of the stat debug stuff in this script 
##It may be bad form but i dont care at the moment 
##Brandon if you see this and also agree its in bad form
##Please screenshot this comment, send it to me, and scold me accordingly 

##Signals for Stats
signal Health_Heal(body)
signal Health_Hurt(body)
signal Stun_Up(body)
signal Stun_Down(body)
signal Stamina_Heal(body)
signal Stamina_Hurt(body)
signal Fear_Up(body)
signal Fear_Down(body)
signal change_room
signal load_scene
##   #NoMoreSignals (for now)


signal interacted(body)

@onready var player = %Player
@export var prompt_msg = "Interact"
@export var prompt_input ="interact"

func get_prompt():
	var key_name = ""
	for action in InputMap.action_get_events(prompt_input):
		if action is InputEventKey:
			key_name = action.as_text_physical_keycode()
			break

	return prompt_msg + "\n[" +key_name + "]"

func interact(body):
	##This is scuffed as hell and i know it, but im going to push through anyway, please forgive me
	if prompt_msg == "Fear Down":
		emit_signal("Fear_Down", body)
	elif prompt_msg == "Fear Up":
		emit_signal("Fear_Up", body)
	elif prompt_msg == "Stamina Down":
		emit_signal("Stamina_Hurt", body)
	elif prompt_msg == "Stamina Up":
		emit_signal("Stamina_Heal", body)
	elif prompt_msg == "Stun Down":
		emit_signal("Stun_Down", body)
	elif prompt_msg == "Stun Up":
		emit_signal("Stun_Up", body)
	elif prompt_msg == "Health Down":
		emit_signal("Health_Hurt", body)
	elif prompt_msg == "Health Up":
		emit_signal("Health_Heal", body)
	elif prompt_msg == "Proceed":
		emit_signal("change_room")
	elif prompt_msg == "Load Scene":
		emit_signal("load_scene")
	
	interacted.emit(body)
	print("Interacted")
	#$AudioStreamPlayer3D.play()
	


func _on_interacted(body):
	pass


##Changed body to player bc of this error msg: 
##Invalid access to property or key 'fear_component' on a base object of type 'Node3D'.


func _on_fear_down(body):
		print("Interacting With Fear Down, Taking Fear Damage")
		var attack = Attack.new()
		attack.fear_damage = 2.5
		player.fear_component.damage(attack)
		print(player.fear_component.fear)
		player.fear_bar._on_fear_changed(player.fear_component.fear)


func _on_fear_up(body):
	print("Interacting With Fear Up, 'Healing' Fear Damage")
	player.fear_component.fear_heal()
	print(player.fear_component.fear)
	player.fear_bar._on_fear_changed(player.fear_component.fear)


func _on_stamina_hurt(body):
	print("Interacting With Stamina Hurt, Taking Stamina Damage")
	var attack = Attack.new()
	attack.stamina_damage = 2.5
	player.stamina_component.damage(attack)
	print(player.stamina_component.stamina)
	player.stamina_bar._on_stamina_changed(player.stamina_component.stamina)


func _on_stamina_heal(body):
	print("Interacting With Stamina Heal, Healing Stamina")
	player.stamina_component.stamina_heal()
	print(player.stamina_component.stamina)
	player.stamina_bar._on_stamina_changed(player.stamina_component.stamina)


func _on_stun_down(body):
	print("Interacting With Stun Down, Taking Stun Damage")
	var attack = Attack.new()
	attack.stun_damage = 2.5
	player.stun_component.damage(attack)
	print(player.stun_component.stun)
	player.stun_bar._on_stun_changed(player.stun_component.stun)


func _on_stun_up(body):
	print("Interacting With Stun Up, 'Healing' Sten Damage")
	player.stun_component.stun_heal()
	print(player.stun_component.stun)
	player.stun_bar._on_stun_changed(player.stun_component.stun)


func _on_health_hurt(body):
	print("Interacting With Health Hurt, Taking Damage")
	var attack = Attack.new()
	attack.health_damage = 2.0
	player.health_component.damage(attack)
	print(player.health_component.health)
	player.health_bar._on_health_changed(player.health_component.health)


func _on_health_heal(body):
	print("Interacting With Health Heal, Healing Health")
	player.health_component.heal()
	print(player.health_component.health)
	player.health_bar._on_health_changed(player.health_component.health)
