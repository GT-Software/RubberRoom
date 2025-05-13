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
