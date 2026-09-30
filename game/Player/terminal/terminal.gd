extends Node2D

var messages := []
var command_args := {}

var system_color := Color("#faff68")
var user_color := Color("00ef00")
var error_color := Color("ff0000")

@onready var chat_panel = $Panel
@onready var chat_text = $Panel/RichTextLabel
@onready var input_box = $LineEdit
@onready var send_button = $Button

var player: CharacterBody3D

func _ready():
	SystemPrint("The system is running")
	player = get_tree().get_first_node_in_group("player")

func get_current_time() -> String:
	var time = Time.get_time_dict_from_system()
	return "[%02d:%02d:%02d]" % [time.hour, time.minute, time.second]

func SystemPrint(text: String):
	chat_text.push_color(system_color)
	chat_text.add_text(get_current_time() + " SYSTEM: " + text + "\n")
	chat_text.pop()

func ErrorPrint(text: String):
	chat_text.push_color(error_color)
	chat_text.add_text(get_current_time() + " ERROR: " + text + "\n")
	chat_text.pop()

func UserPrint(text: String):
	chat_text.push_color(user_color)
	chat_text.add_text(get_current_time() + " YOU: " + text + "\n")
	chat_text.pop()

func _on_send_pressed(_arg = null):
	var text = input_box.text.strip_edges()
	if text == "":
		return
	input_box.text = ""
	UserPrint(text)
	Global.game_settings["last_command"] = text
	parse_command(text)

func _input(event: InputEvent) -> void:
	if not input_box.has_focus():
		return
	if not event.is_action_pressed("ui_up") and not event.is_action_pressed("ui_down"):
		return
	if event.is_action_pressed("ui_up"):
		var last: String = Global.game_settings.get("last_command", "")
		if last != "":
			input_box.text = last
			input_box.caret_column = input_box.text.length()
		else:
			ErrorPrint("No previous command")
	elif event.is_action_pressed("ui_down"):
		input_box.text = ""
		input_box.caret_column = 0
	get_viewport().set_input_as_handled()

func get_script_variables(obj: Object) -> Array:
	var result := []
	for prop in obj.get_property_list():
		if not (prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE):
			continue
		if prop.usage & PROPERTY_USAGE_GROUP:
			continue
		if prop.usage & PROPERTY_USAGE_CATEGORY:
			continue
		if prop.type == TYPE_NIL:
			continue
		var value = obj.get(prop.name)
		result.append({
			"name": prop.name,
			"type": prop.type,
			"value": value
		})
	return result

func handle_set_command(raw_args: String) -> void:
	var cleaned := raw_args.replace("=", " ").strip_edges()
	var tokens := PackedStringArray()
	if cleaned != "":
		tokens = cleaned.split(" ", false)
	if tokens.size() < 3:
		ErrorPrint("Usage: set <global|save|player> <name> = <value>  (value: str, int, float, bool)")
		return
	var source := tokens[0].to_lower()
	var var_name := tokens[1]
	var value_str := tokens[2]
	var new_value: Variant = parse_value(value_str)
	if new_value == null:
		ErrorPrint("Invalid value: only str, int, float, bool are supported")
		return
	match source:
		"global":
			if not Global.game_settings.has(var_name):
				ErrorPrint("Global key not found: " + var_name)
				return
			var old_type = typeof(Global.game_settings[var_name])
			if not is_type_compatible(old_type, new_value):
				ErrorPrint("Type mismatch: '%s' is %s" % [var_name, type_string(old_type)])
				return
			Global.game_settings[var_name] = new_value
			SystemPrint("Global '%s' set to %s" % [var_name, str(new_value)])
		"save":
			var world = Global.get_world(Global.game_settings.word)
			if not world.has(var_name):
				ErrorPrint("Save key not found: " + var_name)
				return
			var old_type = typeof(world[var_name])
			if not is_type_compatible(old_type, new_value):
				ErrorPrint("Type mismatch: '%s' is %s" % [var_name, type_string(old_type)])
				return
			world[var_name] = new_value
			SystemPrint("Save '%s' set to %s" % [var_name, str(new_value)])
		"player":
			var props := get_script_variables(player)
			var found := false
			for v in props:
				if v.name == var_name:
					found = true
					if not is_type_compatible(v.type, new_value):
						ErrorPrint("Type mismatch: '%s' is %s" % [var_name, type_string(v.type)])
						return
					player.set(var_name, new_value)
					SystemPrint("Player '%s' set to %s" % [var_name, str(new_value)])
					break
			if not found:
				ErrorPrint("Player variable not found: " + var_name)
		_:
			ErrorPrint("Unknown source: " + source + " (use global, save or player)")

func parse_value(s: String) -> Variant:
	if s.is_valid_int():
		return s.to_int()
	if s.is_valid_float():
		return s.to_float()
	var lower := s.to_lower()
	if lower == "true" or lower == "false":
		return lower == "true"
	return s

func is_type_compatible(old_type: int, new_value: Variant) -> bool:
	match old_type:
		TYPE_INT:
			return typeof(new_value) == TYPE_INT
		TYPE_FLOAT:
			return typeof(new_value) == TYPE_FLOAT or typeof(new_value) == TYPE_INT
		TYPE_BOOL:
			return typeof(new_value) == TYPE_BOOL
		TYPE_STRING, TYPE_STRING_NAME:
			return typeof(new_value) == TYPE_STRING
		_:
			return false

func parse_command(text: String):
	var first_space := text.find(" ")
	var command := text
	var raw_args := ""
	if first_space != -1:
		command = text.substr(0, first_space)
		raw_args = text.substr(first_space + 1).strip_edges()
	command = command.to_lower()
	var arguments := PackedStringArray()
	if raw_args != "":
		arguments = raw_args.split(" ", false)
	command_args[command] = arguments
	
	match command:
		"teleport", "home":
			player.global_position = Vector3(0, 0, 0)
			SystemPrint("Teleported to coordinates 0, 0, 0")
		"info":
			if arguments.size() == 0:
				ErrorPrint("Usage: info <global|save|player>")
				return
			var target := arguments[0].to_lower()
			match target:
				"global":
					SystemPrint("--- GLOBAL ---")
					for key in Global.game_settings.keys():
						SystemPrint(str(key) + " " + str(Global.game_settings[key]))
				"save":
					SystemPrint("--- SAVE ---")
					var world = Global.get_world(Global.game_settings.word)
					for key in world.keys():
						SystemPrint(str(key) + " " + str(world[key]))
				"player":
					SystemPrint("--- PLAYER ---")
					for v in get_script_variables(player):
						SystemPrint("%s (%s) = %s" % [v.name, type_string(v.type), str(v.value)])
				_:
					ErrorPrint("Unknown info target: " + target + " (use global, save or player)")
		"restart", "respawn":
			player.respawn_player()
			SystemPrint("Player respawned")
		"HP", "hp", "take_damage", "damage":
			var amount := 100
			if arguments.size() >= 1:
				if arguments[0].is_valid_int():
					amount = arguments[0].to_int()
				else:
					ErrorPrint("Invalid argument: must be an integer number")
					return
			player.take_damage(amount)
		"poison":
			var amount := 100
			if arguments.size() >= 1:
				if arguments[0].is_valid_int():
					amount = arguments[0].to_int()
				else:
					ErrorPrint("Invalid argument: must be an integer number")
					return
			player.apply_poison(amount)
		"kill":
			var enemies = get_tree().get_nodes_in_group("enemy")
			if enemies.size() > 0:
				for enemy in enemies:
					if enemy.has_method("take_damage"):
						enemy.take_damage(999999)
				SystemPrint("Killed " + str(enemies.size()) + " enemy/enemies")
			else:
				SystemPrint("No enemies found")
		"sand", "sandbox", "test":
			SceneManager.load_scene_with_loading("res://game/rooms/maps/sandbox.tscn")
		"save":
			Global.save(Global.game_settings["word"])
			SystemPrint("World saved successfully")
		"quit", "exit":
			get_tree().quit()
		"clear":
			chat_text.text = ""
		"message", "msg":
			if raw_args == "":
				ErrorPrint("Usage: msg <text>")
				return
			var message_text := raw_args.replace("_", " ")
			player.warning(message_text)
		"scale", "size":
			if arguments.size() == 0:
				SystemPrint("Current player scale: " + str(player.scale))
			else:
				if not arguments[0].is_valid_float():
					ErrorPrint("Invalid argument: must be a number (e.g., 1.5, 2, 0.5)")
					return
				var scale_value := arguments[0].to_float()
				if scale_value > 0:
					player.scale = Vector3(scale_value, scale_value, scale_value)
					SystemPrint("Player scale set to: " + str(scale_value))
				else:
					ErrorPrint("Scale must be greater than 0")
		"set", "edit", "change", "var":
			handle_set_command(raw_args)
		_:
			ErrorPrint("Unknown command: " + command)
