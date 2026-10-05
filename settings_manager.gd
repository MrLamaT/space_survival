extends Node

const ACTIONS = [
	"+w", "+s", "+a", "+d", "+space", "+shift", "+crouch",
	"+e", "+f", "+q", "UI_click", "UI_alt_click",
	"+1", "+2", "+3", "+4", "+5", "+6", "+7", "+8"
]

var is_rebinding := false
var _default_events: Dictionary = {}

func _ready() -> void:
	for action in ACTIONS:
		_default_events[action] = InputMap.action_get_events(action).duplicate()
	_ensure_bus("SFX")
	_ensure_bus("Music")
	get_tree().node_added.connect(_on_node_added)
	apply_audio_settings()
	apply_saved_bindings()

func _ensure_bus(bus_name: String) -> void:
	if AudioServer.get_bus_index(bus_name) == -1:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.bus_count - 1, bus_name)
		AudioServer.set_bus_send(AudioServer.bus_count - 1, "Master")


func _on_node_added(node: Node) -> void:
	if node is AudioStreamPlayer or node is AudioStreamPlayer2D or node is AudioStreamPlayer3D:
		_route_audio_node.call_deferred(node)


func _route_audio_node(node: Node) -> void:
	if not is_instance_valid(node) or not node.is_inside_tree():
		return
	if node.is_in_group("music"):
		node.set("bus", "Music")
	else:
		node.set("bus", "SFX")

func apply_audio_settings() -> void:
	var gui: Dictionary = Global.game_settings["gui_settings"]
	_set_bus_percent("SFX", float(gui.get("sound_volume", 100.0)))
	_set_bus_percent("Music", float(gui.get("music_volume", 100.0)))


func _set_bus_percent(bus_name: String, percent: float) -> void:
	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index == -1:
		return
	var linear := clampf(percent / 100.0, 0.0, 1.0)
	AudioServer.set_bus_mute(bus_index, linear <= 0.0)
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(maxf(linear, 0.0001)))


func set_volume(setting_name: String, percent: float) -> void:
	if setting_name != "sound_volume" and setting_name != "music_volume":
		return
	Global.game_settings["gui_settings"][setting_name] = clampf(percent, 0.0, 100.0)
	apply_audio_settings()
	Global.save_game_settings()

func apply_saved_bindings() -> void:
	var saved: Dictionary = Global.game_settings.get("key_bindings", {})
	for action in ACTIONS:
		if not saved.has(action) or not InputMap.has_action(action):
			continue
		var event := _event_from_data(saved[action])
		if event != null:
			InputMap.action_erase_events(action)
			InputMap.action_add_event(action, event)

func set_binding(action: String, input_event: InputEvent) -> bool:
	if not ACTIONS.has(action):
		return false
	var data := _event_to_data(input_event)
	if data.is_empty():
		return false
	var clean_event := _event_from_data(data)
	if clean_event == null:
		return false
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, clean_event)
	Global.game_settings["key_bindings"][action] = data
	Global.save_game_settings()
	return true

func reset_bindings() -> void:
	for action in ACTIONS:
		if not InputMap.has_action(action):
			continue
		InputMap.action_erase_events(action)
		for event in _default_events[action]:
			InputMap.action_add_event(action, event)
	Global.game_settings["key_bindings"] = {}
	Global.save_game_settings()

func binding_text(action: String) -> String:
	var events := InputMap.action_get_events(action)
	if events.is_empty():
		return "—"
	var event: InputEvent = events[0]
	if event is InputEventKey:
		var code: int = event.physical_keycode if event.physical_keycode != 0 else event.keycode
		return OS.get_keycode_string(code)
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_LEFT: return "Mouse Left"
			MOUSE_BUTTON_RIGHT: return "Mouse Right"
			MOUSE_BUTTON_MIDDLE: return "Mouse Middle"
			MOUSE_BUTTON_WHEEL_UP: return "Wheel Up"
			MOUSE_BUTTON_WHEEL_DOWN: return "Wheel Down"
			_: return "Mouse %d" % event.button_index
	return event.as_text()

func _event_to_data(event: InputEvent) -> Dictionary:
	if event is InputEventKey:
		var code: int = event.physical_keycode if event.physical_keycode != 0 else event.keycode
		if code != 0:
			return {"type": "key", "code": code}
	if event is InputEventMouseButton:
		return {"type": "mouse", "button": event.button_index}
	return {}

func _event_from_data(data: Variant) -> InputEvent:
	if not (data is Dictionary):
		return null
	if data.get("type") == "key":
		var code := int(data.get("code", 0))
		if code == 0:
			return null
		var key_event := InputEventKey.new()
		key_event.physical_keycode = code as Key
		return key_event
	if data.get("type") == "mouse":
		var button := int(data.get("button", 0))
		if button < 1:
			return null
		var mouse_event := InputEventMouseButton.new()
		mouse_event.button_index = button as MouseButton
		return mouse_event
	return null
