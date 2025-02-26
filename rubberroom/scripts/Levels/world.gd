extends Node3D

@onready var player = %Player
@onready var change_room_button: Interactable = $"NavigationRegion3D/Base World/Interactables/Change Room Button"
@onready var load_scene_button: Interactable = $"NavigationRegion3D/Base World/Interactables/Load Scene Button"
@onready var spawnpoint = $"Spawn Point Debug Marker"
@onready var camera = $"Camera Controller/PhantomCamera3D"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	change_room_button.connect("change_room", spawn_room)
	load_scene_button.connect("load_scene", load_new_level)
	spawn_player_controller()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func spawn_player_controller():
	# Add player into scene at position spawnpoint
	var player_scene = load("res://scenes/Player/player.tscn")
	var instance = player_scene.instantiate()
	get_tree().current_scene.add_child(instance)
	player_scene.global_position = spawnpoint.global_position
	player_scene.global_position.y += 1
	
	# Add rotation point and camera anchor under player for Phantom Camera
	var rotation_point = Node3D.new()
	var camera_anchor = Node3D.new()
	rotation_point.name = "RotationPoint"
	instance = rotation_point.instantiate()
	get_tree(). get_node("Player").add_child(instance)
	instance = camera_anchor.instantiate()
	get_tree().get_node("Player").get_child("RotationPoint").add_child(instance)
	camera_anchor.position = Vector3(1.5, 1, 1.5)
	
	camera.follow_target = camera_anchor
	

func spawn_room():
	var new_room_scene = RoomManager.get_random_room(false)  # Pick a room and remove it from the sack
	if new_room_scene:
		var new_room = new_room_scene.instantiate()
		add_child(new_room)  # Add it to the scene tree
		new_room.global_transform.origin = Vector3(110, 0, 0)  # Adjust position if needed
		
		# Place player at Spawnpoint marker
		player.global_position = spawnpoint.global_position
		player.global_position.y += 1
		print('Room generated!')

func load_new_level():
	SceneManager.load_scene("res://scenes/Levels/Test Levels/primitive_old_boy.tscn")
