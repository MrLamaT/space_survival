extends TextureRect

class_name ItemSlot

@export var slot_index: int = 0
@export var panel_id: String = "inventory"

signal left_clicked(panel_id, slot_index)
signal right_clicked(panel_id, slot_index)

var item_name: String = ""
var item_count: int = 0

func _ready():
	update_slot()

func update_slot():
	if item_name == "" or item_count == 0:
		texture = null
		tooltip_text = ""
		modulate = Color(1.0, 1.0, 1.0, 0.0)
	else:
		var icon_path = "res://assets/item/%s.png" % item_name.replace(" ", "_").to_lower()
		if ResourceLoader.exists(icon_path):
			texture = load(icon_path)
		else:
			texture = null
			print("Иконка не найдена: ", icon_path)
		tooltip_text = item_name
		modulate = Color(1, 1, 1, 1)

func set_item(new_item_name: String, new_count: int = 1):
	item_name = new_item_name
	item_count = new_count
	update_slot()

func clear_slot():
	item_name = ""
	item_count = 0
	update_slot()

func _gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			left_clicked.emit(panel_id, slot_index)
			get_viewport().set_input_as_handled()
			
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			right_clicked.emit(panel_id, slot_index)
			get_viewport().set_input_as_handled()

func _on_mouse_entered():
	if item_name != "":
		modulate = Color(1.0, 1.0, 1.0, 1.0)

func _on_mouse_exited():
	if item_name != "":
		modulate = Color(1.0, 1.0, 1.0, 1.0)
