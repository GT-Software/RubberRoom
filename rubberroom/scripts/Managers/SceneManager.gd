# Scene Manager (WIP)
# Author: Brandon Grunes
# Do not Touch without permission of Author
# Description:

extends Node

# Emitted everytime to update progress bar as needed
signal progress_changed(progress)
# Emitted when the load is completed, finish up the loading animation
signal load_done

var loading_screen_path : String = "res://scenes/UI/loading_screen.tscn"
var load_screen = load(loading_screen_path)
var loaded_resource : PackedScene
var scene_path : String
var progress: Array = []

var use_sub_threads : bool = true

## [SceneManager load_scene(_scene_path : String)]
## [br]Prepares the scene for a loading task. This function instantiates a loading scene to the tree
## to hide the background processes of another scene loading.
## [br][param _scene_path] is the path to the scene that will be loaded 
func load_scene(_scene_path : String) -> void:
	scene_path = _scene_path
	
	# Instantiate loading scene and add it to the tree
	var new_loading_screen = load_screen.instantiate()
	get_tree().get_root().add_child(new_loading_screen)
	
	# Connect progress_changed signal to update_progress_bar in loading screen
	self.progress_changed.connect(new_loading_screen.update_progress_bar)
	# Connect load_done signal to start_outro_animation in loading screen
	self.load_done.connect(new_loading_screen.start_outro_animation)
	
	await Signal(new_loading_screen, "loading_screen_has_full_coverage")
	
	start_load()
	
# Use threading to load scene
# use_sub_threads uses multiple threads to load scene, leave as false if slow
func start_load() -> void:
	var state = ResourceLoader.load_threaded_request(scene_path, "", use_sub_threads)
	if state == OK:
		print("Load Threaded Request OK")
		set_process(true)

func _process(_delta):
	var load_status = ResourceLoader.load_threaded_get_status(scene_path, progress)
	match load_status:
		0, 2: #? THREAD_LOAD_INVALID_RESOURCE, THREAD_LOAD_FAILED
			set_process(false)
			return
		1: #? THREAD_LOAD_IN_PROGRESS
			emit_signal("progress_changed", progress[0])
		3: #? THREAD_LOAD_LOADED
			print("Getting Loading Thread...")
			loaded_resource = ResourceLoader.load_threaded_get(scene_path)
			emit_signal("progress_changed", 1.0)
			emit_signal("load_done")
			print("Scene Loaded, opening scene...")
			get_tree().change_scene_to_packed(loaded_resource)
