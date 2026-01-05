extends Node2D

var messages := []
var command_args := {}

var system_color := Color("e6d91aff")
var user_color := Color("00ef00")
var error_color := Color("ff0000")

@onready var chat_panel = $Panel
@onready var chat_text = $Panel/RichTextLabel
@onready var input_box = $LineEdit
@onready var send_button = $Button

var player: CharacterBody3D
var cheat_mod: bool = false

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
	parse_command(text)

func get_available_items() -> Array:
	var items = []
	var dir = DirAccess.open("res://chapter2/assets/items/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".png.import") and not dir.current_is_dir():
				items.append(file_name.replace(".png.import", ""))
			file_name = dir.get_next()
		dir.list_dir_end()
	items.sort()
	return items

func show_available_items():
	var items = get_available_items()
	if items.size() > 0:
		SystemPrint("Available items:")
		for item in items:
			SystemPrint("• " + item)
	else:
		ErrorPrint("No items found in the items directory")

func parse_command(text: String):
	var parts = text.split(" ")
	var command = parts[0].to_lower()
	var argument = ""
	if parts.size() > 1:
		argument = parts[1]
	command_args[command] = argument

	match command:
		"cheat":
			SystemPrint("Cheats included")
			cheat_mod = true
		"ghost", "noclip":
			if cheat_mod:
				SystemPrint("Ghost mode has been changed")
				player.ghost_cheat()
			else:
				ErrorPrint("No rights")
		"teleport":
			if cheat_mod:
				player.global_position = Vector3(0, 0, 0)
				SystemPrint("Teleported to coordinates 0, 0, 0")
			else:
				ErrorPrint("No rights")
		"give":
			if cheat_mod:
				if argument == "":
					ErrorPrint("Usage: give [item_name]")
					SystemPrint("Type 'give list' to see all available items")
					return
				if argument.to_lower() == "list":
					show_available_items()
					return
				var item_path = "res://chapter2/assets/items/%s.png" % argument
				if not ResourceLoader.exists(item_path):
					ErrorPrint("Item not found: " + argument)
					SystemPrint("Available items:")
					var items = get_available_items()
					for item in items:
						SystemPrint("• " + item)
					return
				if Global.game_settings["Item"] == "":
					Global.game_settings["Item"] = argument
					player.drop_item()
					SystemPrint("Item given: " + argument)
				else:
					ErrorPrint("The hand must be empty")
			else:
				ErrorPrint("No rights")
		"godmode", "god":
			if cheat_mod:
				Global.game_settings["GodMod"] = !Global.game_settings["GodMod"]
				Global.game_settings["HidePlayer"] = Global.game_settings["GodMod"]
				SystemPrint("God mode changed")
			else:
				ErrorPrint("No rights")
		"debugging", "deb":
			Global.game_settings["debugging"] = !Global.game_settings["debugging"]
			SystemPrint("debugging mode changed")
		"info":
			if argument == "":
				for key in Global.game_settings.keys():
					var value = Global.game_settings[key]
					SystemPrint(str(key) + " " + str(value))
			else:
				if Global.game_settings.has(argument):
					var value = Global.game_settings[argument]
					SystemPrint(argument + " " + str(value))
				else:
					ErrorPrint("Key not found: " + argument)
		"preset":
			if cheat_mod:
				if argument == "":
					SystemPrint("Usage: preset [0-5]")
					return
				
				if not argument.is_valid_int():
					ErrorPrint("Preset value must be an integer number from 0 to 5")
					return
				
				var preset_value = argument.to_int()
				if preset_value < 0 or preset_value > 5:
					ErrorPrint("Preset value must be from 0 to 5 (got: " + argument + ")")
					return
				
				# Устанавливаем новое значение
				Global.game_settings["preset"] = preset_value
				SystemPrint("Preset value set to: " + str(preset_value))
			else:
				ErrorPrint("No rights")
		"restart", "respawn":
			if cheat_mod:
				player.respawn_player()
				SystemPrint("Player respawned")
			else:
				ErrorPrint("No rights")
		"kill", "HP", "hp":
			if cheat_mod:
				if argument == "":
					player.PlayerDeath(-1)
					SystemPrint("Player killed")
				else:
					if argument.is_valid_int():
						var damage_value = argument.to_int()
						player.PlayerDeath(damage_value)
						SystemPrint("Player killed")
					else:
						ErrorPrint("Invalid argument: must be an integer number")
			else:
				ErrorPrint("No rights")
		"clear":
			chat_text.text = ""
		"quit", "exit":
			get_tree().quit()
		"light":
			if argument == "":
				ErrorPrint("Usage: light [color_name|null]")
				return
			if argument.to_lower() == "null":
				player.get_node("head/Camera3D/SpotLight3D").visible = false
				player.get_node("head/Camera3D/SpotLight3D2").visible = false
				SystemPrint("Flashlights disabled")
			else:
				var color = Color(argument)
				if color == Color(0, 0, 0, 1) and argument.to_lower() != "black":
					ErrorPrint("Invalid color: " + argument)
					SystemPrint("Use color names (red, blue, green) or hex codes (#ff0000)")
					return
				var light1 = player.get_node("head/Camera3D/SpotLight3D")
				var light2 = player.get_node("head/Camera3D/SpotLight3D2")
				light1.light_color = color
				light2.light_color = color
				SystemPrint("Flashlight color changed to: " + argument)
		"build":
			if cheat_mod:
				if argument == "":
					SystemPrint("Usage: build [object_name|stop|list]")
					SystemPrint("Available objects: light, foundation")
					SystemPrint("Type 'build stop' to exit building mode")
					SystemPrint("Type 'build list' to see all available objects")
					return
				if argument.to_lower() == "stop":
					player.stop_building()
					SystemPrint("Building mode stopped")
					return
				if argument.to_lower() == "list":
					SystemPrint("Available build objects:")
					for obj_name in player.objects.keys():
						SystemPrint("• " + obj_name)
					return
				if player.objects.has(argument.to_lower()):
					player.spawn_ghost_block(argument.to_lower())
					SystemPrint("Building mode: " + argument)
					SystemPrint("Controls:")
					SystemPrint("  • LMB - Place object")
					SystemPrint("  • R - Rotate object")
					SystemPrint("  • F3 - Delete object (aim at it)")
					SystemPrint("  • Type 'build stop' to exit")
				else:
					ErrorPrint("Unknown build object: " + argument)
					SystemPrint("Available objects: light, foundation")
			else:
				ErrorPrint("No rights")
		_:
			ErrorPrint("Unknown command: " + command)
