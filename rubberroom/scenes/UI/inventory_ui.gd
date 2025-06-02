extends Control
class_name InventoryUI

@onready var panel: Panel = $Panel
@onready var grid_container: GridContainer = $GridContainer
@onready var player : CharacterBody3D = %Player
@onready var item_ammo: Label = $"Item Ammo"
@onready var item_name: Label = $"Item Name"
@onready var slot_scene : PackedScene = preload("res://scenes/UI/slot.tscn")

## Reference to the player inventory resource
var inventory : Inventory
## Index of current selected slot
var selected_slot : int = -1 
## Boolean to check if the selected_slot variable has been changed
var selection_changed : bool = false
## Tween for smooth animations
var tween: Tween

var style_unselected = preload("res://assets/materials/Styles/slot_unselected.tres")
var style_selected = preload("res://assets/materials/Styles/slot_selected.tres")

func _ready() -> void:
	visible = false
	grid_container.columns = 2
	
	if player.inventory:
		# Update UI when inventory changes
		inventory = player.inventory
		inventory.connect("inventory_changed", Callable(self, "update_inventory_ui"))
		update_inventory_ui()
	else:
		print("InventoryUI: Inventory not found in player!")
	

func open_inventory():
	inventory = player.inventory
	visible = true
	
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(panel, "modulate", Color(0.173, 0.173, 0.173, 0.850), 1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Engine.time_scale = 0.5
	
func close_inventory():
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "modulate", Color(0.173, 0.173, 0.173, 1), 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Engine.time_scale = 1.0
	
	if selection_changed and player.has_method("equip_weapon"):
		player.equip_weapon(player.inventory.get_item(selected_slot))
		selection_changed = false
		
	visible = false


func update_inventory_ui():
	# Clear existing slots
	for child in grid_container.get_children():
		child.queue_free()
	
	# Dynamically adjust columns based on inventory size
	if inventory:
		var item_count = inventory.get_max_slots()
		grid_container.columns = clamp(ceil(sqrt(item_count)), 2, 6)
	
	# Create a slot for each item
	var index = 0
	for item in inventory.get_items():
		var slot = create_inventory_slot(item, index)
		grid_container.add_child(slot)
		index += 1
	
	# Ensure valid slots
	if selected_slot >= inventory.get_size():
		selected_slot = -1
	
	update_selected_item()


func create_inventory_slot(item, index: int) -> Control:
	var slot = slot_scene.instantiate()
	slot.name = "Slot_" + str(index)
	
	# If theres an item at that index, get the icon for it.
	# Otherwise, placeholder for now
	var icon
	if inventory.get_item(index) != null:
		icon = TextureRect.new()
		icon.texture = preload("res://assets/images/icon.svg") # default godot icon
		icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		icon.size_flags_vertical = Control.SIZE_EXPAND_FILL
		slot.add_child(icon)
	
	# Connect input events
	slot.mouse_entered.connect(Callable(self, "_on_slot_mouse_entered").bind(index))
	slot.gui_input.connect(Callable(self, "_on_slot_gui_input").bind(index))
	
	return slot


func _on_slot_mouse_entered(index: int):
	# Highlight slot on hover
	var slot = grid_container.get_child(index)
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(slot, "scale", Vector2(1.2, 1.2), 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	# Reset other slots
	for i in range(grid_container.get_child_count()):
		if i != index:
			var other_slot = grid_container.get_child(i)
			tween.parallel().tween_property(other_slot, "scale", Vector2(1, 1), 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)


func _on_slot_gui_input(event: InputEvent, index: int):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		#S Select slot on click
		selected_slot = index
		selection_changed = true
		update_selected_item()

func update_selected_item():
	if selected_slot >= 0 and selected_slot < inventory.get_max_slots():
		var item = inventory.get_item(selected_slot)
		
		item_name.text = item.name if item else ""
		if item is Ranged:
			item_ammo.text = str(player.ammo_manager.get_magazine()) + " / " + str(player.ammo_manager.get_ammo(item.ammo_type))
	else:
		item_name.text = ""
		item_ammo.text = ""
		selected_slot = -1
		
	# Update slot highlights
	for i in range(grid_container.get_child_count()):
		var slot = grid_container.get_child(i)
		
		if i == selected_slot:
			slot.add_theme_stylebox_override("panel", style_selected)
		else:
			slot.add_theme_stylebox_override("panel", style_unselected)

func _input(event: InputEvent):
	pass
	## Keyboard/controller navigation
	#if event.is_action_pressed("ui_right"):
		#if selected_slot < grid_container.get_child_count() - 1:
			#selected_slot += 1
			#selection_changed = true
			#update_selected_item()
	#elif event.is_action_pressed("ui_left"):
		#if selected_slot > 0:
			#selected_slot -= 1
			#selection_changed = true
			#update_selected_item()
	#elif event.is_action_pressed("ui_down"):
		#if selected_slot + grid_container.columns < grid_container.get_child_count():
			#selected_slot += grid_container.columns
			#selection_changed = true
			#update_selected_item()
	#elif event.is_action_pressed("ui_up"):
		#if selected_slot - grid_container.columns >= 0:
			#selected_slot -= grid_container.columns
			#selection_changed = true
			#update_selected_item()
