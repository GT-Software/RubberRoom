class_name Ranged extends WeaponResource


@export var ammo_type: int = AmmoType.NONE
@export var max_ammo: int = 0
@export var magazine_size: int = 0
@export var fire_rate: float = 0.0  # Shots per second
@export var reload_time: float = 0.0  # Seconds
@export var projectile_scene: PackedScene = null
@export var projectile_speed: float = 0.0
@export var spread: float = 0.0  # Accuracy/spread in degrees
@export var projectile_count: int = 1  # For shotguns with multiple projectiles


## Return a group of all the class member variables as a [Dictionary]
func to_dict() -> Dictionary:
	return {
		"name" : name,
		"classification" : classification,
		"model_scene" : model_scene,
		"type" : type,
		"ammo_type" : ammo_type,
		"max_ammo" : max_ammo,
		"magazine_size" : magazine_size,
		"fire_rate" : fire_rate,
		"reload_time" : reload_time,
		"projectile_scene" : projectile_scene,
		"projectile_speed" : projectile_speed,
		"spread" : spread,
		"projectile_count" : projectile_count
	}
	
	## Load the [param data] ([Dictionary]) into a new instance of a [WeaponResource]
static func from_dict(data : Dictionary) -> Ranged:
	var instance = Ranged.new()
	instance.name = data["name"]
	instance.classification = data["classification"]
	
	if data.has("model_scene") and data["model_scene"] != "":
		instance.model_scene = load(data["scene_path"])
	
	instance.type = data["type"]
	instance.ammo_type = data["ammo_type"]
	instance.max_ammo = data["max_ammo"]
	instance.magazine_size = data["magazine_size"]
	instance.fire_rate = data["fire_rate"]
	instance.reload_time = data["reload_time"]
	instance.projectile_scene = data["projectile_scene"]
	instance.projectile_speed = data["projectile_speed"]
	instance.spread = data["spread"]
	instance.projectile_count = data["projectile_count"]
	
	return instance
