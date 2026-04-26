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
		"noclip", "fly":
			SystemPrint("Noclip toggled")
			player.ghost_cheat()
		"ghost":
			SystemPrint("Ghost mode has been changed")
			Global.game_settings["GhostMod"] = !Global.game_settings["GhostMod"]
		"teleport", "home":
			player.global_position = Vector3(0, 0, 0)
			SystemPrint("Teleported to coordinates 0, 0, 0")
		"godmode", "god":
			Global.game_settings["GodMod"] = !Global.game_settings["GodMod"]
			SystemPrint("God mode changed")
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
		"restart", "respawn":
			player.respawn_player()
			SystemPrint("Player respawned")
		"HP", "hp":
			if argument == "":
				player.HP(100)
			else:
				if argument.is_valid_int():
					var damage_value = argument.to_int()
					player.HP(damage_value)
				else:
					ErrorPrint("Invalid argument: must be an integer number")
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
			SceneManager.load_scene_with_loading("res://chapter2/rooms/maps/sandbox.tscn")
		"give":
			player.openUI("cheat_give")
			SystemPrint("Opening the item issue menu")
		"save":
			player.save()
			SystemPrint("World saved successfully")
		"quit", "exit":
			get_tree().quit()
		"clear":
			chat_text.text = ""
		"quit", "exit":
			get_tree().quit()
		"smaa", "antialiasing":
			match argument:
				"on", "1", "true":
					_set_smaa(true)
					SystemPrint("SMAA Anti-aliasing: ON")
				"off", "0", "false":
					_set_smaa(false)
					SystemPrint("SMAA Anti-aliasing: OFF")
				_:
					var current = ProjectSettings.get_setting("rendering/anti_aliasing/quality/screen_space_aa")
					_set_smaa(current != 1)
					SystemPrint("SMAA Anti-aliasing: " + ("ON" if current != 1 else "OFF"))
		"+":
			NavigationServer3D.set_debug_enabled(true)
		_:
			ErrorPrint("Unknown command: " + command)

func _set_smaa(enabled: bool):
	var viewport = get_viewport()
	if enabled:
		viewport.screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
	else:
		viewport.screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED

func _get_current_msaa() -> int:
	match get_viewport().msaa_3d:
		Viewport.MSAA_DISABLED: return 0
		Viewport.MSAA_2X: return 2
		Viewport.MSAA_4X: return 4
		Viewport.MSAA_8X: return 8
		_: return 0
