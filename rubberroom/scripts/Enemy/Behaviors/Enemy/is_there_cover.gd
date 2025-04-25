extends ConditionLeaf


func tick(actor, blackboard: Blackboard):
	if get_tree().get_nodes_in_group("cover"):
		return SUCCESS
	
	print("No cover objects available!")
	return FAILURE
