class_name Melee extends WeaponResource


## Return a group of all the class member variables as a [Dictionary]
func to_dict() -> Dictionary:
	return {
		"name" : name,
		"classification" : classification,
		"model_scene" : model_scene,
		"type" : type,
	}

## Load the [param data] ([Dictionary]) into a new instance of a [WeaponResource]
static func from_dict(data : Dictionary) -> Melee:
	var instance = Melee.new()
	instance.name = data["name"]
	instance.classification = data["classification"]
	
	if data.has("model_scene") and data["model_scene"] != "":
		instance.model_scene = load(data["scene_path"])
	
	instance.type = data["type"]
	
	return instance
