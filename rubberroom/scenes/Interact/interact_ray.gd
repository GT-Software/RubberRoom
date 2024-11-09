extends RayCast3D
@onready var prompt: Label = $Prompt


func _physics_process(delta: float) -> void:
	prompt.text = ""
	
	
	if is_colliding():
		var collider = get_collider()
		if collider.is_in_group("interactable"):
			prompt.text = collider.get_prompt()
			
			if Input.is_action_just_pressed(collider.prompt_input):
				collider.interact(owner)
