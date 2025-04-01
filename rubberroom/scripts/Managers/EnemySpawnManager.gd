extends Node

var sack_res = preload('res://data/enemy_sack.tres')

# threat_level will tell the system what enemy classes should be spawning.
# higher threat level means harder/more complex enemies spawn in a room randomly.
var threat_level = 0

# Spawn random enemies based on number of markers and spawn percentage chance
func spawn_enemies(markers : Array):
	pass

# Choose an enemy to spawn
func choose_enemy() -> PackedScene:
	return null
