extends Area3D


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		body.is_in_range = true


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		body.is_in_range = false
