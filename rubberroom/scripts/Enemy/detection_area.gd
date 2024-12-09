extends Area3D

signal is_detected(target)

var last_position
var random_position
var target

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		print("Player is Detected!")
		target = body
		is_detected.emit(target)
	
	
	## Handle raycast query
	#var space = get_world_3d().direct_space_state
	#var query = PhysicsRayQueryParameters3D.create(global_position, global_position - body.global_position)
	#var collision = space.intersect_ray(query)
	
	
	#if collision.collider == player:
		#print("Ray collision detected with player!")
		#true_detection = true
	#else:
		#print("No player detected!")
	


func _on_body_exited(body: Node3D) -> void:
	print("Player is Lost!")
	target = null
	is_detected.emit(target)
