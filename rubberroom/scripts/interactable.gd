extends CollisionObject3D
class_name Interactable

signal interacted(body)

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
	interacted.emit(body)
	print("Interacted")
	$AudioStreamPlayer3D.play()
	


func _on_interacted(body):
	pass
