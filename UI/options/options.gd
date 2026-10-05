extends Node2D

@onready var general_panel = $Panel/general/VBoxContainer
@onready var general_scroll: ScrollContainer = $Panel/general
@onready var controls_panel = $Panel/controls/VBoxContainer
@onready var controls_scroll: ScrollContainer = $Panel/controls

const ACTION_NAMES := {
	"+w": "Forward", "+s": "Backward", "+a": "Left", "+d": "Right",
	"+space": "Jump", "+shift": "Sprint", "+crouch": "Crouch",
	"+e": "Interact", "+f": "Flashlight", "+q": "Spawn menu",
	"UI_click": "Fire", "UI_alt_click": "Alt fire",
	"+1": "Slot 1", "+2": "Slot 2", "+3": "Slot 3", "+4": "Slot 4",
	"+5": "Slot 5", "+6": "Slot 6", "+7": "Slot 7", "+8": "Slot 8"
}

var binding_buttons: Dictionary = {}
var pending_action := ""

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
	general_panel.get_node("Sound/HSlider").value = float(Global.game_settings.gui_settings.sound_volume)
	general_panel.get_node("Music/HSlider").value = float(Global.game_settings.gui_settings.music_volume)
	general_panel.get_node("FOV/HSlider").value = float(Global.game_settings.gui_settings.fov)
	_build_binding_controls()

func _exit_tree() -> void:
	SettingsManager.is_rebinding = false

func _build_binding_controls() -> void:
	for action in SettingsManager.ACTIONS:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 150)
		controls_panel.add_child(row)
		var label := Label.new()
		label.text = ACTION_NAMES.get(action, action)
		label.custom_minimum_size = Vector2(310, 0)
		row.add_child(label)
		var button := Button.new()
		button.custom_minimum_size = Vector2(250, 38)
		button.text = SettingsManager.binding_text(action)
		button.pressed.connect(_on_binding_button_pressed.bind(action))
		row.add_child(button)
		binding_buttons[action] = button

func _on_binding_button_pressed(action: String) -> void:
	pending_action = action
	SettingsManager.is_rebinding = true
	binding_buttons[action].text = "..."

func _input(event: InputEvent) -> void:
	if not SettingsManager.is_rebinding or pending_action.is_empty():
		return
	if event is InputEventKey:
		if not event.pressed or event.echo:
			return
		if event.keycode == KEY_ESCAPE or event.physical_keycode == KEY_ESCAPE:
			_finish_rebinding()
			get_viewport().set_input_as_handled()
			return
	elif event is InputEventMouseButton:
		if not event.pressed:
			return
	else:
		return
	if SettingsManager.set_binding(pending_action, event):
		_finish_rebinding()
	get_viewport().set_input_as_handled()

func _finish_rebinding() -> void:
	if binding_buttons.has(pending_action):
		binding_buttons[pending_action].text = SettingsManager.binding_text(pending_action)
	pending_action = ""
	SettingsManager.is_rebinding = false
	
func _on_label_button_pressed(id: String) -> void:
	match id:
		"general":
			general_scroll.visible = true
			controls_scroll.visible = false
		"controls":
			general_scroll.visible = false
			controls_scroll.visible = true
		"back":
			if SettingsManager.is_rebinding:
				_finish_rebinding()
			if get_parent().has_node("menu"):
				visible = false
				get_parent().get_node("menu").visible = true
			else:
				var player = get_tree().get_first_node_in_group("player")
				if player:
					player.openUI("pause")
				queue_free()

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

func _on_sound_value_changed(value: float) -> void:
	SettingsManager.set_volume("sound_volume", value)
	Global.save(0)

func _on_music_value_changed(value: float) -> void:
	SettingsManager.set_volume("music_volume", value)
	Global.save(0)

func _on_fov_value_changed(value: float) -> void:
	Global.game_settings["gui_settings"]["fov"] = value
	Global.save(0)
