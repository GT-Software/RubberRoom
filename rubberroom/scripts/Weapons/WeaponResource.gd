class_name WeaponResource
extends Item


@export var damage: float = 0.0

# Special effects
@export var muzzle_flash_scene: PackedScene = null
@export var sound_fire: AudioStream = null
@export var sound_reload: AudioStream = null
@export var sound_empty: AudioStream = null
@export var sound_equip:  AudioStream = null

@export var sound_hit: AudioStream = null
# Dictionary to map AnimationTree node names to AnimationPlayer animation names

@export var animation_mapping: Dictionary = {}  # AttackType -> Animation Name
@export var node_mapping: Dictionary = {}      # AttackType -> AnimationTree Node Path
@export var buffer_times: Dictionary = {}      # AttackType -> Buffer Time

## Return a group of all the class member variables as a [Dictionary]
func to_dict() -> Dictionary:
	var base_dict = super.to_dict()
	base_dict["damage"] = damage
	base_dict["muzzle_flash_scene"] = muzzle_flash_scene.resource_path if muzzle_flash_scene else ""
	base_dict["sound_fire"] = sound_fire.resource_path if sound_fire else ""
	base_dict["sound_reload"] = sound_reload.resource_path if sound_reload else ""
	base_dict["sound_empty"] = sound_empty.resource_path if sound_empty else ""
	base_dict["sound_equip"] = sound_equip.resource_path if sound_equip else ""
	base_dict["animation_mapping"] = animation_mapping
	return base_dict

## Load the [param data] ([Dictionary]) into a new instance of a [WeaponResource]
static func from_dict(data : Dictionary) -> WeaponResource:
	var instance = WeaponResource.new()
	instance.name = data["name"]
	instance.classification = data["classification"]
	if data.has("model_scene") and data["model_scene"] != "":
		instance.model_scene = load(data["model_scene"])
	instance.type = data["type"]
	instance.damage = data["damage"]
	if data.has("muzzle_flash_scene") and data["muzzle_flash_scene"] != "":
		instance.muzzle_flash_scene = load(data["muzzle_flash_scene"])
	if data.has("sound_fire") and data["sound_fire"] != "":
		instance.sound_fire = load(data["sound_fire"])
	if data.has("sound_reload") and data["sound_reload"] != "":
		instance.sound_reload = load(data["sound_reload"])
	if data.has("sound_empty") and data["sound_empty"] != "":
		instance.sound_empty = load(data["sound_empty"])
	if data.has("sound_equip") and data["sound_equip"] != "":
		instance.sound_equip = load(data["sound_equip"])
	instance.attack_animations = data["attack_animations"]
	return instance
