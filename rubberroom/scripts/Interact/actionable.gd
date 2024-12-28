# Actionable.gd
extends Interactable

@export var dialogue_resource: DialogueResource
@export var dialogue_start: String = "start"

# Add a flag to prevent multiple activations
var is_active: bool = false

func interact(body):
	# Prevent interaction if already active
	if is_active:
		return
	is_active = true
	action()

func action() -> void:
	#only if within a certian radius of the actionable
	print("Action method called")
	# Connect to the DialogueManager signals
	DialogueManager.connect("got_dialogue", _on_got_dialogue)
	DialogueManager.connect("dialogue_ended", _on_dialogue_finished)
	DialogueManager.show_dialogue_balloon(dialogue_resource, dialogue_start)

func _on_got_dialogue(line):
	# This will be called when the first line of dialogue is encountered
	_on_dialogue_started()
	# Disconnect to prevent this from being called multiple times
	DialogueManager.disconnect("got_dialogue", _on_got_dialogue)

func _on_dialogue_started():
	# Pause the game
	#get_tree().paused = true
	# Release mouse capture
	#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	pass

func _on_dialogue_finished(resource):
	# Re-enable interaction when the dialogue ends
	is_active = false
	DialogueManager.disconnect("dialogue_ended", _on_dialogue_finished)
