extends Node3D

@onready var player = %Player
@onready var change_room_button: Interactable = $"NavigationRegion3D/Base World/Interactables/Change Room Button"
@onready var load_scene_button: Interactable = $"NavigationRegion3D/Base World/Interactables/Load Scene Button"
@onready var spawnpoint = get_tree().find_child('Spawn Point Debug Marker')

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	change_room_button.connect("change_room", spawn_room)
	load_scene_button.connect("load_scene", load_new_level)
	spawn_player_controller()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func spawn_player_controller():
	var player_scene = load("res://scenes/Player/player.tscn")
	var instance = player_scene.instantiate()
	get_tree().current_scene.add_child(instance)
	player_scene.global_position = spawnpoint.global_position
	player_scene.global_position.y += 1

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
