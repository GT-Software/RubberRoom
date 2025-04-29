class_name WeaponResource
extends Resource

enum Classification {
	UNARMED,
	BLUNT,
	BLADED,
	SPECIAL
}

@export var name: String = ""
@export var classification: int = Classification.UNARMED
@export var damage: float = 0.0
@export var model_scene: PackedScene = null
