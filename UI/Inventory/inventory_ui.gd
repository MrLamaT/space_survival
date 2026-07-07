extends Control

@onready var inventory_panel: InventoryPanel = $InventoryPanel

func _ready():
	update_inventory()

func update_inventory():
	inventory_panel.update_display()

func add_item(panel_id: String, item_name: String):
	var world = Global.get_world(Global.game_settings.word)
	if not world.has("inventory"):
		world["inventory"] = {}
	if not world["inventory"].has(panel_id):
		world["inventory"][panel_id] = []
	world["inventory"][panel_id].append(item_name)
	update_inventory()
	return true

func get_item_at_slot(panel_id: String, slot_index: int) -> String:
	var world = Global.get_world(Global.game_settings.word)
	if world.has("inventory") and world["inventory"].has(panel_id):
		var items: Array = world["inventory"][panel_id]
		if slot_index < items.size():
			return items[slot_index]
	return ""
