extends Area3D
@onready var player = %Player

signal range(in_range : bool)

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
