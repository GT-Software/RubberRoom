extends ActionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	blackboard.set_value("new weapon found", false)
	actor.anim_tree.set("parameters/OneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	return FAILURE
