extends Area3D

var detected = false
var last_position
var random_position

func _on_body_entered(body: Node3D) -> void:
	print("Player is Detected!")
	detected = true


func _on_body_exited(body: Node3D) -> void:
	print("Player is Lost!")
	detected = false
	last_position = body.global_position
