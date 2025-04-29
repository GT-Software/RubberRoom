extends Area3D

@export var weapon_resource: WeaponResource

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body.has_method("equip_weapon"):
		body.equip_weapon(weapon_resource)
		queue_free()
