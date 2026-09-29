extends Node2D

@onready var general_panel = $Panel/general/VBoxContainer

func _ready() -> void:
	if Global.game_settings["gui_settings"]["Language"] == "English":
		general_panel.get_node("Language/OptionButton").selected = 0
	else:
		general_panel.get_node("Language/OptionButton").selected = 1
	general_panel.get_node("Speedometer/CheckBox").button_pressed = Global.game_settings["gui_settings"]["Speed"]
	general_panel.get_node("Coords/CheckBox").button_pressed = Global.game_settings["gui_settings"]["Coords"]
	general_panel.get_node("FPS/CheckBox").button_pressed = Global.game_settings["gui_settings"]["FPS"]
	general_panel.get_node("CrosshairType/OptionButton").selected = Global.game_settings["gui_settings"]["crosshair"] - 1
	if Global.game_settings["gui_settings"]["ch_scale"] == 2.5:
		general_panel.get_node("CrosshairSize/OptionButton").selected = 0
	if Global.game_settings["gui_settings"]["ch_scale"] == 5.0:
		general_panel.get_node("CrosshairSize/OptionButton").selected = 1
	if Global.game_settings["gui_settings"]["ch_scale"] == 7.5:
		general_panel.get_node("CrosshairSize/OptionButton").selected = 2
	general_panel.get_node("Sensitivity/HSlider").value = float(Global.game_settings.gui_settings.sensitivity)
	
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
	Global.game_settings["gui_settings"]["Speed"] = general_panel.get_node("Speedometer/CheckBox").button_pressed
	Global.save(0)

func _on_Coords_pressed() -> void:
	Global.game_settings["gui_settings"]["Coords"] = general_panel.get_node("Coords/CheckBox").button_pressed
	Global.save(0)

func _on_FPS_pressed() -> void:
	Global.game_settings["gui_settings"]["FPS"] = general_panel.get_node("FPS/CheckBox").button_pressed
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

func _on_sensitivity_value_changed(value: float) -> void:
	Global.game_settings["gui_settings"]["sensitivity"] = value
	Global.save(0)
