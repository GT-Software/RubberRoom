extends Control

class_name InventoryUI


@export var player : CharacterBody3D = null
@export var columns : int = 4 # Number of columns in the grid
@export var slot_size : Vector2 = Vector2(64, 64) # Size of each slot
@export var slot_spacing : int = 10 # Spacing between slots
@export var selected_scale : float = 1.2 # Scale factor for selected slot
@export var animation_duration : float = 0.2 # Duration for slot highlight animation

var inventory : Inventory # Reference to the player inventory resource
var selected_slot : int = -1 # Index of current selected slot
var tween: Tween # For smooth anim

@onready var grid_container = $GridContainer
@onready var item_name_label = $ItemNameLabel
@onready var item_ammo_label = $ItemAmmoLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Configure GridContainer
	grid_container.columns = 4
	grid_container.add_theme_constant_override("h_separation", slot_spacing)
	grid_container.add_theme_constant_override("v_separation", slot_spacing)
	
	if player.inventory:
		# Update UI when inventory changes
		if inventory:
			inventory = player.inventory
			inventory.connect("inventory_changed", Callable(self, "update_inventory_ui"))
			update_inventory_ui()
		else: 
			push_error("InventoryUI: Inventory not found in player!")
	else:
		push_error("InventoryUI: player not assigned or invalid!")

func update_inventory_ui():
	# Clear existing slots
	for child in grid_container.get_children():
		child.queue_free()
	
	# Dynamically adjust columns based on inventory size
	if inventory:
		var item_count = inventory.get_max_slots()
		columns = clamp(ceil(sqrt(item_count)), 2, 6) # Dynamic columns
		grid_container.columns = columns
	
	# Create a slot for each item
	var index = 0
	for item in inventory.get_items():
		var slot = create_inventory_slot(item, index)
		grid_container.add_child(slot)
		index += 1
	
	# Ensure selected slot is valid
	if selected_slot >= inventory.get_size():
		selected_slot = -1
	# Update selected item details
	update_selected_item()

func create_inventory_slot(item, index : int)  -> Control:
	var slot = PanelContainer.new()
	slot.custom_minimum_size = slot_size
	slot.name = "Slot_" + str(index)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.1, 0.8) # Dark, semi-transparent background
	style.border_color = Color(1, 1, 1, 0.5) # Light border
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_width_left = 2
	style.border_width_right = 2
	style.shadow_color = Color(0, 0, 0, 0.3)
	style.shadow_size = 5
	slot.add_theme_stylebox_override("panel", style)
	
	# Add item icon (placeholder for now)
	var icon = TextureRect.new()
	icon.texture = preload("res://assets/images/icon.svg") #item.icon if item and item.icon else 
	icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	icon.size_flags_vertical = Control.SIZE_EXPAND_FILL
	slot.add_child(icon)
	
	# Connect input events
	slot.mouse_entered.connect(Callable(self, "_on_slot_mouse_entered").bind(index))
	slot.gui_input.connect(Callable(self, "_on_slot_gui_input").bind(index))
	
	return slot

func _on_slot_mouse_entered(index : int):
	# Highlight slot on hover
	var slot = grid_container.get_child(index)
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(slot, "scale", Vector2(selected_scale, selected_scale), animation_duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	# Reset other slots
	for i in range(grid_container.get_child_count()):
		if i != index:
			var other_slot = grid_container.get_child(i)
			tween.parallel().tween_property(other_slot, "scale", Vector2(1, 1), animation_duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

func _on_slot_gui_input(event : InputEvent, index : int):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# Select slot on click
		selected_slot = index
		update_selected_item()

func update_selected_item():
	if selected_slot >= 0 and selected_slot < inventory.get_max_slots():
		var item = inventory.get_item(selected_slot)
		if item is Ranged:
			item_name_label.text = item.name if item else ""
			item_ammo_label.text = str(player.ammo_manager.get_magazine()) + " / " + str(player.ammo_manager.get_ammo(item.ammo_type))
	else:
		item_name_label.text = ""
		item_ammo_label.text = ""
		selected_slot = -1
	
	# Update slot highlights
	for i in range(grid_container.get_child_count()):
		var slot = grid_container.get_child(i)
		var style = slot.get_theme_stylebox("panel").duplicate()
		if i == selected_slot:
			style.border_color = Color(1, 0.5, 0, 1) # Orange highlight for selected slot
			style.shadow_color = Color(1, 0.5, 0, 0.5)
		else:
			style.border_color = Color(1, 1, 1, 0.5) # Default Border
			style.shadow_color = Color(0, 0, 0, 0.3)
		slot.add_theme_stylebox_override("panel", style)

func open_inventory():
	# Fade-in animation
	modulate = Color(1, 1, 1, 0)
	visible = true
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func close_inventory():
	# Fade-out animation
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(self.set.bind("visible", false))
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _exit_tree():
	if tween:
		tween.kill()

func _input(event : InputEvent):
	# Keyboard/controller navigation
	if event.is_action_pressed("ui_right"):
		if selected_slot < grid_container.get_child_count() - 1:
			selected_slot += 1
			update_selected_item()
	elif event.is_action_pressed("ui_left"):
		if selected_slot > 0:
			selected_slot -= 1
			update_selected_item()
	elif event.is_action_pressed("ui_down"):
		if selected_slot + columns < grid_container.get_child_count():
			selected_slot += columns
			update_selected_item()
	elif event.is_action_pressed("ui_up"):
		if selected_slot - columns >= 0:
			selected_slot -= columns
			update_selected_item()
