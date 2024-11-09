extends Node
class_name NPC

var prompt_msg = "Interact"
var prompt_input ="interact"
@onready var canvas_layer = %CanvasLayer
@onready var dialogue_box = load("res://scenes/dialogue_box.tscn")
#Assign specific NPC value 
#Init movement 



#Init Dial


#When Interact with NCP
func get_prompt():
	var key_name = ""
	for action in InputMap.action_get_events(prompt_input):
		if action is InputEventKey:
			key_name = action.as_text_physical_keycode()
			break

	return prompt_msg + "\n[" +key_name + "]"


#Interact Activates Camera change and pop up talk box
#Grab specific dialogue and animate box accordingly 
func interact(body):
	print("Interacted")
	var instance = dialogue_box.instantiate()
	canvas_layer.add_child(instance)
	
	

#Open Dial Box w/ Choices
