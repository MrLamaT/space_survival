extends Control

@onready var inventory_panel: InventoryPanel = $InventoryPanel

var right_click_menu: PopupMenu

func _ready():
	right_click_menu = PopupMenu.new()
	right_click_menu.add_item("Удалить", 0)
	right_click_menu.id_pressed.connect(_on_right_click_menu_selected)
	add_child(right_click_menu)
	
	inventory_panel.slot_right_clicked.connect(_on_slot_right_clicked)
	
	var world = Global.get_world(Global.game_settings.word)
	if world.has("inventory") and world["inventory"].has(inventory_panel.panel_id):
		update_inventory()

var selected_slot_data = {}

func _on_slot_right_clicked(panel_id: String, slot_index: int):
	selected_slot_data = {"panel_id": panel_id, "slot_index": slot_index}
	
	var world = Global.get_world(Global.game_settings.word)
	if world.has("inventory") and world["inventory"].has(panel_id):
		var items: Array = world["inventory"][panel_id]
		if slot_index < items.size() and items[slot_index] != "":
			# Показываем меню возле курсора мыши
			right_click_menu.position = get_global_mouse_position()
			right_click_menu.popup()

func _on_right_click_menu_selected(id: int):
	match id:
		0: # Удалить
			remove_item(selected_slot_data["panel_id"], selected_slot_data["slot_index"])

func remove_item(panel_id: String, slot_index: int):
	var world = Global.get_world(Global.game_settings.word)
	
	if world.has("inventory") and world["inventory"].has(panel_id):
		var items: Array = world["inventory"][panel_id]
		
		if slot_index < items.size():
			# Удаляем предмет по индексу
			items.remove_at(slot_index)
			
			# Обновляем данные в глобальном хранилище
			world["inventory"][panel_id] = items
			
			# Обновляем отображение
			update_inventory()

func update_inventory():
	inventory_panel.update_display()

func add_item(panel_id: String, item_name: String):
	var world = Global.get_world(Global.game_settings.word)
	
	if not world.has("inventory"):
		world["inventory"] = {}
	
	if not world["inventory"].has(panel_id):
		world["inventory"][panel_id] = []
	
	# Добавляем предмет в конец
	world["inventory"][panel_id].append(item_name)
	
	# Обновляем отображение
	update_inventory()

func get_item_at_slot(panel_id: String, slot_index: int) -> String:
	var world = Global.get_world(Global.game_settings.word)
	
	if world.has("inventory") and world["inventory"].has(panel_id):
		var items: Array = world["inventory"][panel_id]
		if slot_index < items.size():
			return items[slot_index]
	
	return ""
