extends GridContainer

class_name InventoryPanel

@export var panel_id: String = "inventory"
@export var grid_width: int = 5
@export var grid_height: int = 4

signal slot_left_clicked(panel_id, slot_index)
signal slot_right_clicked(panel_id, slot_index)

var slots: Array[ItemSlot] = []

func _ready():
	#var world = Global.get_world(Global.game_settings.word)
	#var backpack = world["build"]["backpack"]
	#if panel_id == "inventory":
	#	if backpack == 1:
	#		grid_height = 4
	#	if backpack == 2:
	#		grid_height = 5
	#	if backpack == 3:
	#		grid_height = 5
	#		grid_width = 5
	columns = grid_width
	for i in range(grid_width * grid_height):
		var slot_scene = load("res://UI/Inventory/ItemSlot.tscn")
		var slot: ItemSlot = slot_scene.instantiate()
		slot.slot_index = i
		slot.panel_id = panel_id
		slot.left_clicked.connect(_on_slot_left_clicked)
		slot.right_clicked.connect(_on_slot_right_clicked)
		add_child(slot)
		slots.append(slot)
	
	update_display()

func update_display():
	var world = Global.get_world(Global.game_settings.word)
	if not world.has("inventory") or not world["inventory"].has(panel_id):
		return
	var items: Array = world["inventory"][panel_id]
	for slot in slots:
		slot.clear_slot()
	var slot_index = 0
	for item_name in items:
		if slot_index < slots.size():
			slots[slot_index].set_item(item_name)
			slot_index += 1

func _on_slot_left_clicked(clicked_panel_id: String, slot_index: int):
	if clicked_panel_id == panel_id:
		slot_left_clicked.emit(panel_id, slot_index)

func _on_slot_right_clicked(clicked_panel_id: String, slot_index: int):
	if clicked_panel_id == panel_id:
		slot_right_clicked.emit(panel_id, slot_index)
