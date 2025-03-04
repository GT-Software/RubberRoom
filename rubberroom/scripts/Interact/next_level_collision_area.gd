extends Interactable

@export var scene_name : String

func _ready() -> void:
	prompt_msg = "Interact"
	prompt_input = "interact"

func get_prompt():
	var key_name = ""
	for action in InputMap.action_get_events(prompt_input):
		if action is InputEventKey:
			key_name = action.as_text_physical_keycode()
			break

	return prompt_msg + "\n[" +key_name + "]"


func interact(body):
	emit_signal("load_scene", scene_name)


func _on_body_entered(body: Node3D) -> void:
	print("Entered a Progression Area")


func _on_body_exited(body: Node3D) -> void:
	print("Exited a Progression Area")
