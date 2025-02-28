# Room Manager (WIP)
# Author: Brandon Grunes
# Do not Touch without permission of Author
# Description:
##	This is the managing singleton for the 'Sack of Rooms' Mechanic of Rubber Room.
##	[br]Please refer to the RoomManager.gd script for more details.[br]
##	@experimental: This is a work in progress manager


#func spawn_room():
	#var new_room_scene = RoomManager.get_random_room(false)  # Pick a room and remove it from the sack
	#if new_room_scene:
		#var new_room = new_room_scene.instantiate()
		#add_child(new_room)  # Add it to the scene tree
		#new_room.global_transform.origin = Vector3(0, 0, 0)  # Adjust position if needed

# TODO: Create weighted rooms, Create scripted event room change function

extends Node

# THE SACK
var room_sack 

## [method RoomManager._ready()]
## When the game is run, this function will preload all the levels that are needed for the game to begin
## Do [b]not[/b] call this method
# Add in levels by including the following line(s) in room_sack
# (Do not forget to remove pass):
# preload(<path to file>)
func _ready() -> void:
	room_sack = [
		{ "scene": "res://scenes/Levels/Test Levels/primitive_old_boy.tscn", "weight": 0},
		{ "scene": "res://scenes/Levels/Test Levels/super_primitive_box_room.tscn", "weight": 0},
		{ "scene": "res://scenes/Levels/Test Levels/large_room.tscn", "weight": 0},
		{ "scene": "res://scenes/Levels/Test Levels/L_room.tscn", "weight": 0},
		{ "scene": "res://scenes/Levels/Test Levels/reverse_l_room.tscn", "weight": 0},
	]

## [method RoomManager.get_random_room(remove_after_selection : bool = false, weight_limit : int = 0)] 
## Returns a randomly selected [PackedScene] for the next level.
## [param remove_after_selection] is a boolean that lets the function know if the room must be
## deleted after it has been selected. Set to false by default. [param weight_limit] is an integer
## that describes the level of priority the selected room needs to be. 
## Allows for common and special rooms.
## [br] Called before [method SceneManager.load_scene].
func get_random_room(remove_after_selection : bool = false, weight_limit : int = 0) -> String:
	# If the sack is empty, return a null value (This should not happen unless there are no rooms preloaded!)
	if room_sack.is_empty():
		return 'null'
	if weight_limit < 0:
		return 'null'
	
	var break_loop = false
	var room
	while(!break_loop):
		var index = randi_range(0, room_sack.size() - 1)
		
		if room_sack[index]["weight"] >= weight_limit:
			room = room_sack[index]["scene"]
			print("Loading ", room)
		
			# Remove the room if needed
			if remove_after_selection:
				room_sack.remove_at(index)
			break_loop = true
	return room
	
	


## [method RoomManager.room_event_trigger()]
## Returns a designated room ([PackedScene]) for the next level. Usually used for special/scripted
## game events. [br] [param room_name] String that holds the name of a unique room scene.
## [br] Called before [method SceneManager.load_scene].
func room_event_trigger(room_index : int) -> String:
	if room_index >= room_sack.size():
		return "null"
	
	return room_sack[room_index]['scene']

## [method RoomManager.reset_sack()]
## If sack breaks or expected game event happens, this will reset the sack for whatever reason
func reset_sack():
	_ready()
