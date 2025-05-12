class_name WeaponResource
extends Resource

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
@export var damage: float = 0.0
@export var model_scene: PackedScene = null

# Ranged weapon specific properties
@export var is_ranged: bool = false
@export var ammo_type: int = AmmoType.NONE
@export var max_ammo: int = 0
@export var magazine_size: int = 0
@export var fire_rate: float = 0.0  # Shots per second
@export var reload_time: float = 0.0  # Seconds
@export var projectile_scene: PackedScene = null
@export var projectile_speed: float = 0.0
@export var spread: float = 0.0  # Accuracy/spread in degrees
@export var projectile_count: int = 1  # For shotguns with multiple projectiles

# Special effects
@export var muzzle_flash_scene: PackedScene = null
@export var sound_fire: AudioStream = null
@export var sound_reload: AudioStream = null
@export var sound_empty: AudioStream = null
