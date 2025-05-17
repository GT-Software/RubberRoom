class_name WeaponResource
extends Item


@export var damage: float = 0.0

# Special effects
@export var muzzle_flash_scene: PackedScene = null
@export var sound_fire: AudioStream = null
@export var sound_reload: AudioStream = null
@export var sound_empty: AudioStream = null
@export var sound_equip:  AudioStream = null

## Return a group of all the class member variables as a [Dictionary]
func to_dict() -> Dictionary:
	return {
		"name" : name,
		"classification" : classification,
		"model_scene" : model_scene,
		"type" : type,
	}

## Load the [param data] ([Dictionary]) into a new instance of a [WeaponResource]
static func from_dict(data : Dictionary) -> WeaponResource:
	var item_type = data.get("type", "Item")	# Default to Item if no type is found
	
	var instance
	match item_type:
		"WeaponResource":
			instance = WeaponResource.new()
		"Melee":
			instance = Melee.new()
		"Ranged":
			instance = Ranged.new()
		_:
			instance = Item.new()
			instance.name = data["name"]
			instance.classification = data["classification"]
			
			if data.has("model_scene") and data["model_scene"] != "":
				instance.model_scene = load(data["model_scene"])	# load the scene as packed scene
			
			instance.type = data["type"]
			
			return instance
	
	if instance:
		return instance.from_dict(data)
	else:
		print("Warning: Could not find class for type: ", item_type)
		return null
