extends ActionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	actor.rotate_self = true
	actor.rotate_target = actor.nav_agent.get_next_path_position()
	actor.rotate_node = actor.target
	return SUCCESS
