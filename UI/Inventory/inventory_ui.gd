extends Control

@onready var inventory_panel: InventoryPanel = $InventoryPanel
@onready var right_click_menu: PopupMenu = $PopupMenu

func _ready():
	update_inventory()

func _on_slot_right_clicked(panel_id: String, slot_index: int):
	print(panel_id, slot_index)
	var world = Global.get_world(Global.game_settings.word)
	if world.has("inventory") and world["inventory"].has(panel_id):
		var items: Array = world["inventory"][panel_id]
		if slot_index < items.size() and items[slot_index] != "":
			right_click_menu.position = get_global_mouse_position()
			right_click_menu.popup()

func _on_right_click_menu_selected(id: int):
	match id:
		0: # Удалить
			remove_item(inventory_panel.panel_id, 0)
		1: # Сортировать
			sort_inventory(inventory_panel.panel_id)

func remove_item(panel_id: String, slot_index: int):
	var world = Global.get_world(Global.game_settings.word)
	if world.has("inventory") and world["inventory"].has(panel_id):
		var items: Array = world["inventory"][panel_id]
		if slot_index < items.size():
			items.remove_at(slot_index)
			world["inventory"][panel_id] = items
			update_inventory()

func sort_inventory(panel_id: String):
	var world = Global.get_world(Global.game_settings.word)
	if world.has("inventory") and world["inventory"].has(panel_id):
		var items: Array = world["inventory"][panel_id]
		items.sort()
		world["inventory"][panel_id] = items
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
