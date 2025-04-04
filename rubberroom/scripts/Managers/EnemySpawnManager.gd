extends Node

var sack_res = preload('res://data/enemy_sack.tres')

# threat_level will tell the system what enemy classes should be spawning.
# higher threat level means harder/more complex enemies spawn in a room randomly.
var threat_level = 0

# Spawn random enemies based on number of markers and spawn percentage chance
func spawn_enemies(markers : Array, level : int = 0):
	var current_sack : Array
	
	# Depending on the progression level, spawn these types of enemies
	match level:
		0:
			current_sack.push_back(sack_res.sack["basic enemy"])
		1:
			current_sack.push_back(sack_res.sack["basic enemy"])
			current_sack.push_back(sack_res.sack["ranged enemy"])
		2: 
			current_sack.push_back(sack_res.sack["basic enemy"])
			current_sack.push_back(sack_res.sack["ranged enemy"])
			current_sack.push_back(sack_res.sack["heavy enemy"])
	
	# STOP. HAMMER TIME.
	
	var numEnemies = ceil((markers.size() + current_sack.size()) / 2)
	var markersToSpawn : Array
	for marker in markers:
		var randNum = randf_range(0.0, 100.0)
		
		# if randNum is 50.0 or higher, choose this marker
		if randNum >= 50.0:
			markersToSpawn.push_back(marker)
	
	for marker in markersToSpawn:
		var curr = 0
		if current_sack.size() == 1:
			var enemy = current_sack.front().instantiate()
			add_child(enemy)
			enemy.global_position = marker.global_position
		else:
			var enemy = current_sack[0].instantiate()
			add_child(enemy)
			enemy.global_position = marker.global_position

# Choose an enemy to spawn
func choose_enemy() -> PackedScene:
	return null
