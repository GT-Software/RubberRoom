extends Area3D
@onready var player = %Player

signal range(in_range : bool)
signal shot_at(is_shot : bool)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		print("In melee range!")
		range.emit(true)
	else:
		print("Can't Find Player!")


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		print("Not in melee range!")
		range.emit(false)
	else:
		print("Can't find Player!")


func _on_area_entered(area: Area3D) -> void:
	if area.collision_layer == 3:	# If projectile came from enemy, return
		return
	if area.is_in_group("projectile") and area.collision_layer == 1:	# If projectile entered mele range and came from the player
		print("Shots Fired at Me!")
		shot_at.emit(true)
