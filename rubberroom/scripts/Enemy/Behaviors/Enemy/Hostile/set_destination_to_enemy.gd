extends ActionLeaf

# TODO: Research and confirm the issues:
# How to get it to run like the patrol state so that it continues until it is in range to attack.
# How to traverse the tree properly so it does not return here if you are not detected
# How to keep the enemy in the hostile state while its running

# Set target to player, look at player
func tick(actor, _blackboard):
	print("Enemy: Chasing Player")
	actor.update_target_location(actor.target.position)
	actor.update_nav_agent()
	return SUCCESS
