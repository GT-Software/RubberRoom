class_name Item extends Resource

enum Classification {
	UNARMED,
	BLUNT,
	BLADED,
	RANGED,
	SPECIAL
}

enum AmmoType {
	NONE,
	PISTOL,
	SHOTGUN,
	RIFLE,
	ENERGY
}

@export var name: String = ""
@export var classification: int = Classification.UNARMED
@export var model_scene: PackedScene = null
@export var type : String

func to_dict() -> Dictionary:
	return {
		"name" : name,
		"classification" : classification,
		"model_scene" : model_scene,
		"type" : type
	}

static func from_dict(data : Dictionary):
	var item_type = data.get("type", "Item")	# Default to Item if no type is found
	
	var instance
	match item_type:
		"WeaponResource":
			instance = WeaponResource.from_dict(data)
		_:
			instance = Item.new()
			instance.name = data["name"]
			instance.classification = data["classification"]
			
			if data.has("model_scene") and data["model_scene"] != "":
				instance.model_scene = load(data["model_scene"])	# load the scene as packed scene
			
			instance.type = data["type"]
			
			return instance
	
	if instance:
		return instance
	else:
		print("Warning: Could not find class for type: ", item_type)
		return null
