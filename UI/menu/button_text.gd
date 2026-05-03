extends Label

@export var textLabel_en: String = ""
@export var textLabel_ru: String = ""
@export var setting = false

@export var target_node: NodePath = "": 
	set(value):
		target_node = value

@export var button_id: String = "":  
	set(value):
		button_id = value

func _ready() -> void:
	if setting:
		if Global.game_settings["gui_settings"][button_id]:
			text = textLabel_en + " [ON]"
		else:
			text = textLabel_en + " [OFF]"
	else:
		if Global.game_settings["gui_settings"]["Language"] == "русский":
			text = textLabel_ru
		else:
			text = textLabel_en

func _on_button_mouse_entered() -> void:
	modulate = Color("#faff68")

func _on_button_mouse_exited() -> void:
	modulate = Color("ffffffff")

func _on_button_pressed() -> void:
	if not is_inside_tree():
		return
	var target = get_node(target_node)
	if target.has_method("_on_label_button_pressed"):
		target._on_label_button_pressed(button_id)
	else:
		push_error("Target node doesn't have '_on_label_button_pressed' method!")
