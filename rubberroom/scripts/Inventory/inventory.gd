## The inventory class is specifically for storing items. It is meant to be the
## base for the player inventory and home storage
## [br]
## @experimental
# Author: Brandon Grunes

class_name Inventory

## The max slots the inventory instance can hold.
## Can be changed
var max_slots
## The actual storage variable for all the items
var content : Dictionary[int, Item]
## The number of slots available
var size

## Initialize content with null values for all [member Inventory.max_slots].
## [param max_slots],default value of [code]2[/code], allows for inventories with
## varying sizes 
func _init(max_slots : int = 2):
	for i in range(max_slots):
		content.set(i, null)
	
	self.max_slots = max_slots
	size = max_slots

## Adds an item ([Item]) to the inventory if there is a free slot.
## Returns a Dictionary[bool, String] for [code]true[/code] and [code]""[/code] 
## if the item was added. Otherwise, returns
## [code]false[/code] with an error message as the value.
func add_item(item : Item) -> Dictionary[bool, String]:
	# Is there space for a new item?
	if size == 0:
		return {false : "Inventory: No open slots available"}
	# Did the caller bring a valid item?
	elif !item or item != Item:
		return {false : "Inventory: item does not exist"}
	
	# Find the nearest empty slot and add the item there. Reduce size to show
	# available slots.
	for i in range(max_slots):
		if content[i] == null or !content.has(i):
			content[i] = item
			size -= 1
			return {true : ""}
	
	return {false : "Inventory: Failed to add item."}

## Get the item at a specified slot.
## [br] [param slot] is the key for the item.
func get_item(slot : int) -> Item:
	return content.get(slot, null)

## Takes an item ([Item]) and moves it to the specified [param slot].
## Returns a Dictionary[bool, String] for [code]true[/code] and [code]""[/code] 
## if the item was added. Otherwise, returns
## [code]false[/code] with an error message as the value.
func add_item_to_slot(item : Item, slot : int) -> Dictionary[bool, String]:
	if content[slot] != null:
		return {false : "Inventory: Item is already in that slot"}
	
	content.set(slot, item)
	return {true : ""}

## Removes an item ([Item]) from [member Inventory.content]
## Returns a Dictionary[bool, String] for [code]true[/code] and [code]""[/code] 
## if the item was removed. Otherwise, returns
## [code]false[/code] with an error message as the value.
func remove_item(index : int) -> Dictionary[bool, String]:
	if !content.has(index):
		return {false : "Inventory: Item does not exist"}
	
	content.erase(index)
	return {true : ""}

## Clear the inventory of items for any reason (i.e. Player dies)
func clear_inventory():
	content.clear()
	size = max_slots

## Get all inventory items in the form of an array
func get_items() -> Array[Item]:
	var list = content.values()
	return list

## See if the inventory has a specific [member item] (see [Item]).
## Returns [code]true[/code] if the item exists in the inventory, otherwise
## returns [code]false[/code]
func has_item(item: Item) -> bool:
	# Look through all the values in the dictonary
	for obj in content.values():
		# if obj exists and the obj's name is the same as the item's name,
		# return true.
		if obj != null and obj.name == item.name:
			return true
	return false

## Swap two items based on their slot indices.
func swap_items(slot_a : int, slot_b : int):
	# get the item in the slot or null
	var item_a = content.get(slot_a, null)
	var item_b = content.get(slot_b, null)
	
	# Swap the values
	content.set(slot_a, item_b)
	content.set(slot_b, item_a)

## Increase the maximum number of slots the inventory can hold.
func increase_max_slots(add_value : int):
	for i in range(max_slots, max_slots + add_value):
		content.set(i, null)

	max_slots += add_value
	size += add_value
