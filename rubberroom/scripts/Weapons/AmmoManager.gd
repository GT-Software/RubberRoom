class_name AmmoManager
extends Node

signal ammo_changed(type, current, max_ammo)
signal magazine_changed(current, max_size)
signal reload_complete

# Ammo types match those in WeaponResource
enum AmmoType {
	NONE,
	PISTOL,
	SHOTGUN,
	RIFLE,
	ENERGY
}

# Total ammo by type
var ammo_reserves = {
	AmmoType.NONE: 0,
	AmmoType.PISTOL: 30,
	AmmoType.SHOTGUN: 12,
	AmmoType.RIFLE: 60,
	AmmoType.ENERGY: 100
}

# Maximum ammo by type
var max_ammo = {
	AmmoType.NONE: 0,
	AmmoType.PISTOL: 60,
	AmmoType.SHOTGUN: 24,
	AmmoType.RIFLE: 120,
	AmmoType.ENERGY: 200
}

# Current weapon's ammo
var current_ammo_type = AmmoType.NONE
var current_magazine = 0
var current_magazine_size = 0
var is_reloading = false

# Get ammo count for a specific type
func get_ammo(type: int) -> int:
	return ammo_reserves[type]

# Get current magazine ammo
func get_magazine() -> int:
	return current_magazine

# Set current weapon's ammo parameters
func set_current_weapon(weapon: WeaponResource) -> void:
	current_ammo_type = weapon.ammo_type
	current_magazine_size = weapon.magazine_size
	
	# If magazine is empty, auto-reload
	if current_magazine <= 0 and ammo_reserves[current_ammo_type] > 0:
		reload()
	
	# Emit signals for UI updates
	ammo_changed.emit(current_ammo_type, ammo_reserves[current_ammo_type], max_ammo[current_ammo_type])
	magazine_changed.emit(current_magazine, current_magazine_size)

# Use ammo from magazine
func use_ammo(amount: int = 1) -> bool:
	if current_magazine >= amount:
		current_magazine -= amount
		magazine_changed.emit(current_magazine, current_magazine_size)
		return true
	return false

# Reload current weapon
func reload() -> bool:
	if is_reloading:
		return false
		
	# Can't reload if no ammo or magazine is full
	if ammo_reserves[current_ammo_type] <= 0 or current_magazine >= current_magazine_size:
		return false
	
	is_reloading = true
	
	# Calculate how much ammo to reload
	var needed = current_magazine_size - current_magazine
	var available = min(needed, ammo_reserves[current_ammo_type])
	
	# Update ammo counts
	current_magazine += available
	ammo_reserves[current_ammo_type] -= available
	
	# Emit signals
	ammo_changed.emit(current_ammo_type, ammo_reserves[current_ammo_type], max_ammo[current_ammo_type])
	magazine_changed.emit(current_magazine, current_magazine_size)
	
	# Reload is complete
	is_reloading = false
	reload_complete.emit()
	
	return true

# Add ammo to reserves
func add_ammo(type: int, amount: int) -> void:
	ammo_reserves[type] += amount
	ammo_reserves[type] = min(ammo_reserves[type], max_ammo[type])
	
	# Update UI if it's the current ammo type
	if type == current_ammo_type:
		ammo_changed.emit(type, ammo_reserves[type], max_ammo[type])
