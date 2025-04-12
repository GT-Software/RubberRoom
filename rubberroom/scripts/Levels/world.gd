extends Node3D

@onready var player = %Player
@onready var change_room_button: Interactable = $"NavigationRegion3D/Base World/Interactables/Change Room Button"
@onready var load_scene_button: Interactable = $"NavigationRegion3D/Base World/Interactables/Load Scene Button"
@onready var next_level_collision_area: Area3D = $NextLevelCollisionArea
@onready var spawnpoint = $"Spawn Point Debug Marker"
@onready var camera = $"Camera Controller/PhantomCamera3D"
@onready var camera_zoom = $"Camera Controller/PhantomCamera Zoom In"

var enemies_spawned = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#change_room_button.connect("change_room", spawn_room)
	#load_scene_button.connect("load_scene", load_new_level)
	next_level_collision_area.connect("load_scene", load_new_level)
	await player.ready
	spawn_player_controller()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !enemies_spawned:
		start_enemy_spawning()
		enemies_spawned = true


func spawn_player_controller():
	## Add player into scene at position spawnpoint
	#var player_scene = load("res://scenes/Player/player.tscn")
	#var player_instance = player_scene.instantiate()
	#get_tree().current_scene.add_child(player_instance)
	#var rotation_point = player.find_child("RotationPoint")
	#rotation_point.position = Vector3.ZERO
	#rotation_point.set_as_top_level(false)
	#player.global_position = spawnpoint.global_position
	#player.global_position.y += 1
	#rotation_point.set_as_top_level(true)
	#rotation_point.position = player.position
	#
	## Add rotation point and camera anchor under player for Phantom Camera
	#var rotation_point = Node3D.new()
	#var camera_anchor = Node3D.new()
	#rotation_point.name = "RotationPoint"
	#camera_anchor.name = "Camera Anchor"
	#player_instance.add_child(rotation_point)
	#rotation_point.add_child(camera_anchor)
	#camera_anchor.position = Vector3(1.5, 1, 1.5)
	
	#camera.set_follow_target(player_instance)
	#camera.set_follow_offset(camera_anchor.position)
	pass
	
func start_enemy_spawning():
	var markers = get_tree().get_nodes_in_group("EnemySpawnMarker")
	print("Number of Enemy Markers: ", markers.size())
	EnemySpawnManager.spawn_enemies(player, markers, 0)	# Spawns on markers at level 0

## Deprecated
## [br] Spawns a new room in the same scene. Should not work as [class RoomManager] has been changed to compensate for [class SceneManager]
func spawn_room():
	var new_room_scene = RoomManager.get_random_room()  # Pick a room and remove it from the sack
	if new_room_scene:
		var new_room = new_room_scene.instantiate()
		add_child(new_room)  # Add it to the scene tree
		new_room.global_transform.origin = Vector3(110, 0, 0)  # Adjust position if needed
		
		# Place player at Spawnpoint marker
		player.global_position = spawnpoint.global_position
		player.global_position.y += 1
		print('Room generated!')

func load_new_level(scene_name : String = ""):
	var new_scene
	
	if scene_name == "":
		new_scene = RoomManager.get_random_room()
		SceneManager.load_scene(new_scene)
	else:
		new_scene = RoomManager.room_event_trigger(scene_name.to_int())
		SceneManager.load_scene(new_scene)
	
