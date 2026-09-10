extends Node2D

func _ready() -> void:
	if Global.game_settings["gui_settings"]["Language"] == "English":
		$Panel/ScrollContainer/VBoxContainer/Language/OptionButton.selected = 0
	else:
		$Panel/ScrollContainer/VBoxContainer/Language/OptionButton.selected = 1
	$Panel/ScrollContainer/VBoxContainer/Speedometer/CheckBox.button_pressed = Global.game_settings["gui_settings"]["Speed"]
	$Panel/ScrollContainer/VBoxContainer/Coords/CheckBox.button_pressed = Global.game_settings["gui_settings"]["Coords"]
	$Panel/ScrollContainer/VBoxContainer/FPS/CheckBox.button_pressed = Global.game_settings["gui_settings"]["FPS"]
	$Panel/ScrollContainer/VBoxContainer/CrosshairType/OptionButton.selected = Global.game_settings["gui_settings"]["crosshair"] - 1
	if Global.game_settings["gui_settings"]["ch_scale"] == 2.5:
		$Panel/ScrollContainer/VBoxContainer/CrosshairSize/OptionButton.selected = 0
	if Global.game_settings["gui_settings"]["ch_scale"] == 5.0:
		$Panel/ScrollContainer/VBoxContainer/CrosshairSize/OptionButton.selected = 1
	if Global.game_settings["gui_settings"]["ch_scale"] == 7.5:
		$Panel/ScrollContainer/VBoxContainer/CrosshairSize/OptionButton.selected = 2

func _on_label_button_pressed(id: String) -> void:
	match id:
		"back":
			visible = false
			get_parent().get_node("menu").visible = true

func _on_language_selected(index: int) -> void:
	if index == 0:
		Global.game_settings["gui_settings"]["Language"] = "English"
	else:
		Global.game_settings["gui_settings"]["Language"] = "русский"
	Global.save(0)

func _on_Speed_pressed() -> void:
	Global.game_settings["gui_settings"]["Speed"] = $Panel/ScrollContainer/VBoxContainer/Speedometer/CheckBox.button_pressed
	Global.save(0)

func _on_Coords_pressed() -> void:
	Global.game_settings["gui_settings"]["Coords"] = $Panel/ScrollContainer/VBoxContainer/Coords/CheckBox.button_pressed
	Global.save(0)

func _on_FPS_pressed() -> void:
	Global.game_settings["gui_settings"]["FPS"] = $Panel/ScrollContainer/VBoxContainer/FPS/CheckBox.button_pressed
	Global.save(0)

func _on_crosshair_selected(index: int) -> void:
	Global.game_settings["gui_settings"]["crosshair"] = index + 1
	Global.save(0)

func _on_crosshair_size_selected(index: int) -> void:
	if index == 0:
		Global.game_settings["gui_settings"]["ch_scale"] = 2.5
	if index == 1:
		Global.game_settings["gui_settings"]["ch_scale"] = 5.0
	if index == 2:
		Global.game_settings["gui_settings"]["ch_scale"] = 7.5
	Global.save(0)
