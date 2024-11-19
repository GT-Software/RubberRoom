extends ActionLeaf


func tick(actor, _blackboard):
	actor.attack()
	return SUCCESS
