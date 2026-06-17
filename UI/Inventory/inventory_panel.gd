extends ScrollContainer

class_name InventoryPanel

@export var panel_id: String = "inventory"
@export var grid_width: int = 10
@export var grid_height: int = 5

signal slot_right_clicked(panel_id, slot_index)

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
		slot.right_clicked.connect(_on_slot_right_clicked)
		grid_container.add_child(slot)
		slots.append(slot)

func update_display():
	var world = Global.get_world(Global.game_settings.word)
	if not world.has("inventory") or not world["inventory"].has(panel_id):
		return
	var items: Array = world["inventory"][panel_id]
	ensure_slots(items.size())
	for slot in slots:
		slot.clear_slot()
	var slot_index = 0
	for item_name in items:
		if slot_index < slots.size():
			slots[slot_index].set_item(item_name)
			slot_index += 1
	for i in range(slots.size()):
		slots[i].visible = (i < items.size())

func _on_slot_right_clicked(clicked_panel_id: String, slot_index: int):
	if clicked_panel_id == panel_id:
		slot_right_clicked.emit(panel_id, slot_index)
