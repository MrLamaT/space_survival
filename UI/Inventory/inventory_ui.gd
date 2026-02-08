extends Control

@onready var inventory_panel: InventoryPanel = $InventoryPanel
@onready var inventory_panel2: InventoryPanel
@onready var right_click_menu: PopupMenu = $PopupMenu
@export var inventory2: String
@export var Label2: String

func _ready():
	if inventory2 != "":
		create_second_panel()
	
	if Label2 != "":
		$Label2.text = Label2
	else:
		$Label2.queue_free()
	
	var world = Global.get_world(Global.game_settings.word)
	if world.has("inventory") and world["inventory"].has(inventory_panel.panel_id):
		update_inventory()

func create_second_panel():
	var inventory_panel_scene = load("res://UI/Inventory/InventoryPanel.tscn")
	inventory_panel2 = inventory_panel_scene.instantiate()
	inventory_panel2.panel_id = inventory2
	inventory_panel2.position = Vector2(600.0, 50.0)
	inventory_panel2.scale = Vector2(1.5, 1.5)
	inventory_panel2.z_index = 1
	add_child(inventory_panel2)
	inventory_panel2.slot_left_clicked.connect(_on_slot_left_clicked)
	inventory_panel2.slot_right_clicked.connect(_on_slot_right_clicked)
	var world = Global.get_world(Global.game_settings.word)
	if world.has("inventory") and world["inventory"].has(inventory2):
		inventory_panel2.update_display()

var selected_slot_data = {}

func _on_slot_right_clicked(panel_id: String, slot_index: int):
	print(panel_id, slot_index)
	selected_slot_data = {"panel_id": panel_id, "slot_index": slot_index}
	var world = Global.get_world(Global.game_settings.word)
	if world.has("inventory") and world["inventory"].has(panel_id):
		var items: Array = world["inventory"][panel_id]
		if slot_index < items.size() and items[slot_index] != "":
			right_click_menu.position = get_global_mouse_position()
			right_click_menu.popup()

func _on_right_click_menu_selected(id: int):
	match id:
		0: # Удалить
			remove_item(selected_slot_data["panel_id"], selected_slot_data["slot_index"])
		1: # Сортировать
			sort_inventory(selected_slot_data["panel_id"])

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
	if inventory_panel2 != null:
		inventory_panel2.update_display()

func add_item(panel_id: String, item_name: String):
	var world = Global.get_world(Global.game_settings.word)
	if not world.has("inventory"):
		world["inventory"] = {}
	if not world["inventory"].has(panel_id):
		world["inventory"][panel_id] = []
	var target_panel = null
	if panel_id == inventory_panel.panel_id:
		target_panel = inventory_panel
	elif inventory_panel2 != null and panel_id == inventory_panel2.panel_id:
		target_panel = inventory_panel2
	if target_panel != null:
		var max_slots = target_panel.grid_width * target_panel.grid_height
		var current_items = world["inventory"][panel_id]
		if current_items.size() >= max_slots:
			print("Инвентарь ", panel_id, " полон! Слотов: ", max_slots)
			return false
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

func _on_slot_left_clicked(panel_id: Variant, slot_index: Variant) -> void:
	if inventory_panel2 == null:
		return
	var world = Global.get_world(Global.game_settings.word)
	if not world.has("inventory") or not world["inventory"].has(panel_id):
		return
	var items: Array = world["inventory"][panel_id]
	if slot_index >= items.size() or items[slot_index] == "":
		return  
	var item_name = items[slot_index]
	var shift_pressed = Input.is_key_pressed(KEY_SHIFT)
	if shift_pressed:
		move_all_matching_items(panel_id, item_name)
	else:
		move_single_item(panel_id, slot_index, item_name)

func move_single_item(panel_id: String, slot_index: int, item_name: String):
	var world = Global.get_world(Global.game_settings.word)
	var source_panel = panel_id
	var target_panel = ""
	var target_panel_node = null
	if panel_id == inventory_panel.panel_id:
		target_panel = inventory_panel2.panel_id
		target_panel_node = inventory_panel2
	else:
		target_panel = inventory_panel.panel_id
		target_panel_node = inventory_panel
	var max_slots = target_panel_node.grid_width * target_panel_node.grid_height
	var target_items = []
	if world["inventory"].has(target_panel):
		target_items = world["inventory"][target_panel]
	if target_items.size() >= max_slots:
		print("Целевой инвентарь ", target_panel, " полон! Слотов: ", max_slots)
		return 
	var source_items = world["inventory"][source_panel]
	source_items.remove_at(slot_index)
	world["inventory"][source_panel] = source_items
	if not world["inventory"].has(target_panel):
		world["inventory"][target_panel] = []
	world["inventory"][target_panel].append(item_name)
	update_inventory()

func move_all_matching_items(panel_id: String, item_name: String):
	var world = Global.get_world(Global.game_settings.word)
	var source_panel = panel_id
	var target_panel = ""
	var target_panel_node = null
	if panel_id == inventory_panel.panel_id:
		target_panel = inventory_panel2.panel_id
		target_panel_node = inventory_panel2
	else:
		target_panel = inventory_panel.panel_id
		target_panel_node = inventory_panel
	var max_slots = target_panel_node.grid_width * target_panel_node.grid_height
	var target_items = []
	if world["inventory"].has(target_panel):
		target_items = world["inventory"][target_panel]
	var source_items = world["inventory"][source_panel]
	var items_to_move = []
	for i in range(source_items.size() - 1, -1, -1):
		if source_items[i] == item_name:
			items_to_move.append(source_items[i])
			source_items.remove_at(i)
	if target_items.size() + items_to_move.size() > max_slots:
		print("Недостаточно места в целевом инвентаре!")
		for item in items_to_move:
			source_items.append(item)
		world["inventory"][source_panel] = source_items
		update_inventory()
		return
	for item in items_to_move:
		target_items.append(item)
	world["inventory"][source_panel] = source_items
	world["inventory"][target_panel] = target_items
	print("Перенесено ", items_to_move.size(), " предметов типа: ", item_name)
	update_inventory()
