extends Control

@onready var magazine_label = $AmmoContainer/Magazine
@onready var reserve_label = $AmmoContainer/Reserve

@onready var weapon_name_label = $WeaponNameLabel
@onready var ammo_container = $AmmoContainer

var player

func _ready():
	# Hide UI initially
	ammo_container.visible = false

func setup(player_ref):
	player = player_ref
	player.ammo_manager.ammo_changed.connect(_on_ammo_changed)
	player.ammo_manager.magazine_changed.connect(_on_magazine_changed)
	
	# Also connect to the player's weapon change signal if you have one
	# player.weapon_changed.connect(_on_weapon_changed)

func _on_ammo_changed(type, current, max_ammo):
	reserve_label.text = str(current)
	# Show UI when a ranged weapon is equipped
	ammo_container.visible = true

func _on_magazine_changed(current, max_size):
	magazine_label.text = str(current) + "/" + str(max_size)
	# Show UI when a ranged weapon is equipped
	ammo_container.visible = true

func _on_weapon_changed(weapon):
	weapon_name_label.text = weapon.name
	
	# Show UI only for ranged weapons
	ammo_container.visible = weapon.is_ranged
