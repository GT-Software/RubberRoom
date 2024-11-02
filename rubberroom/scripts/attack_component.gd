class_name Attack
extends Area3D


var health_damage : float
var stamina_damage : float
var stun_damage : float
var fear_damage : float
var knockback_force : float
var attack_position : Vector3

func _init(h_dmg = 2.0, stam_dmg = 0.0, stun_dmg = 0.0, f_dmg = 0.0, kbf_dmg = 0.0, a_pos = Vector3(0, 0, 0)):
	health_damage = h_dmg
	stamina_damage = stam_dmg
	stun_damage = stun_dmg
	fear_damage = f_dmg
	knockback_force = kbf_dmg
	attack_position = a_pos
