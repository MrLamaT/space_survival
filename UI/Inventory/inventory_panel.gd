extends ScrollContainer

class_name InventoryPanel

@export var panel_id: String = "inventory"
@export var grid_width: int = 10
@export var grid_height: int = 5

@onready var grid_container: GridContainer = $GridContainer
var slots: Array[ItemSlot] = []

func _ready():
	grid_container.columns = grid_width
	ensure_slots(grid_width * grid_height)
	update_display()

func ensure_slots(needed_count: int):
	while slots.size() < needed_count:
		var slot_scene = load("res://UI/Inventory/ItemSlot.tscn")
		var slot: ItemSlot = slot_scene.instantiate()
		slot.slot_index = slots.size()
		slot.panel_id = panel_id
		grid_container.add_child(slot)
		slots.append(slot)

func update_display():
	var world = Global.get_world(Global.game_settings.word)
	if not world.has("inventory") or not world["inventory"].has(panel_id):
		return
	var items: Array = world["inventory"][panel_id]
	var grouped_items = {}
	for item_name in items:
		if item_name in grouped_items:
			grouped_items[item_name] += 1
		else:
			grouped_items[item_name] = 1
	var grouped_list = []
	for item_name in grouped_items:
		grouped_list.append({
			"name": item_name,
			"count": grouped_items[item_name]
		})
	for slot in slots:
		slot.clear_slot()
	var slot_index = 0
	for item_data in grouped_list:
		if slot_index < slots.size():
			slots[slot_index].set_item(item_data["name"], item_data["count"])
			slot_index += 1
	for i in range(slots.size()):
		slots[i].visible = (i < grouped_list.size())
