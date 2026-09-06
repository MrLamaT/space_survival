extends Node

var world_1: Dictionary
var world_2: Dictionary
var world_3: Dictionary
var world_4: Dictionary
var world_5: Dictionary

var bonus_level: Dictionary = {
	1: "res://game/rooms/maps/backrooms/backrooms.tscn",
	2: "res://game/rooms/maps/RoP/fnaf.tscn",
	3: "res://game/rooms/maps/endless_parkour/endless_parkour.tscn"
}

var level: Dictionary = {
	-2: "res://game/rooms/maps/simulation/flat.tscn",
	-1: "res://game/rooms/maps/simulation/sandbox.tscn",
	0: "res://UI/start/start.tscn",
	1: "res://game/rooms/maps/RoP/RoP_1.tscn",
	2: "res://game/rooms/maps/RoP/RoP_2.tscn",
	3: "res://game/rooms/maps/RoP/RoP_3.tscn",
	4: "res://game/rooms/maps/RoP/RoP_4.tscn"
}

var game_settings: Dictionary = {
	"gui_settings": {
		"Coords": false,
		"FPS": false,
		"Speed": false,
		"Autosave": true,
		"Language": "English"
	},
	"summon": {
		"name": "phantom",
		"aura": 0,
		"enemyTags": "player",
		"boss": false
	},
	"summon_block": {
		"name": ""
	},
	"CanStandUp": true,
	"IsDying": false,
	"ThrownCamera": null,
	"can_jump": true,
	"affected_by_gravity": true,
	"word": 0,
	"step": 1,
	"UI": false,
	"UI_argument": null,
	"GhostMod": false,
	"checkpoint": Vector3(0.0, 0.0, 0.0),
	"min_y": -5.0,
	"music": ""
}

func _ready():
	reset_world_to_default(1)
	reset_world_to_default(2)
	reset_world_to_default(3)
	reset_world_to_default(4)
	reset_world_to_default(5)
	load_game_settings()
	for i in range(1, 6):
		load_world(i)

func get_world(world_num: int) -> Dictionary:
	match world_num:
		1: return world_1
		2: return world_2
		3: return world_3
		4: return world_4
		5: return world_5
		_: return {}

func save_game_settings():
	var save_file = FileAccess.open("user://game_settings.save", FileAccess.WRITE)
	if save_file:
		save_file.store_line(JSON.stringify(game_settings, "\t"))
		save_file.close()
		print("Game settings saved successfully!")
	else:
		print("Error saving game settings: ", FileAccess.get_open_error())

func load_game_settings():
	if not FileAccess.file_exists("user://game_settings.save"):
		print("No saved game settings found. Using defaults.")
		return
	var save_file = FileAccess.open("user://game_settings.save", FileAccess.READ)
	if save_file:
		var content = save_file.get_as_text()
		save_file.close()
		var json = JSON.new()
		var parsed_result = json.parse(content)
		if parsed_result == OK:
			var loaded_settings = json.get_data()
			for key in loaded_settings:
				if game_settings.has(key):
					game_settings[key] = loaded_settings[key]
			print("Game settings loaded successfully!")
		else:
			print("Error parsing saved settings: ", json.get_error_message(), " at line ", json.get_error_line())
	else:
		print("Error loading game settings: ", FileAccess.get_open_error())

func save_settings(world_num: int = 0):
	if world_num == 0:
		save_game_settings()
	elif world_num >= 1 and world_num <= 5:
		save_world(world_num)
	else:
		print("Error: Invalid world number. Use 0 for game settings or 1-5 for worlds.")

func load_settings(world_num: int = 0):
	if world_num == 0:
		load_game_settings()
	elif world_num >= 1 and world_num <= 5:
		load_world(world_num)
	else:
		print("Error: Invalid world number. Use 0 for game settings or 1-5 for worlds.")

func save_world(world_num: int):
	var world_data = get_world(world_num)
	if world_data.is_empty():
		print("Error: World ", world_num, " not found.")
		return
	var save_file = FileAccess.open("user://world_" + str(world_num) + ".save", FileAccess.WRITE)
	if save_file:
		save_file.store_line(JSON.stringify(world_data, "\t"))
		save_file.close()
		print("World ", world_num, " saved successfully!")
	else:
		print("Error saving world ", world_num, ": ", FileAccess.get_open_error())

func load_world(world_num: int):
	var file_path = "user://world_" + str(world_num) + ".save"
	if not FileAccess.file_exists(file_path):
		print("No saved world ", world_num, " found. Using defaults.")
		return
	var save_file = FileAccess.open(file_path, FileAccess.READ)
	if save_file:
		var content = save_file.get_as_text()
		save_file.close()
		var json = JSON.new()
		var parsed_result = json.parse(content)
		if parsed_result == OK:
			var loaded_world = json.get_data()
			match world_num:
				1: world_1 = loaded_world
				2: world_2 = loaded_world
				3: world_3 = loaded_world
				4: world_4 = loaded_world
				5: world_5 = loaded_world
			print("World ", world_num, " loaded successfully!")
		else:
			print("Error parsing world ", world_num, ": ", json.get_error_message(), " at line ", json.get_error_line())
	else:
		print("Error loading world ", world_num, ": ", FileAccess.get_open_error())

func save(world_num: int = 0):
	save_settings(world_num)
	print("сохранение: ", world_num)

func load(world_num: int = 0):
	load_settings(world_num)

func reset_world_to_default(world_num: int) -> void:
	var default_world = {
		"name": "[NEW GAME " + str(world_num) + "]",
		"mode": 0,
		"stage": 0,
		"level": 0,
		"HP": 100,
		"equipment": [],
		"weapon": ["", "", "", "", ""],
		"costumes": "Classic",
		"inventory": {}
	}
	match world_num:
		1: world_1 = default_world
		2: world_2 = default_world
		3: world_3 = default_world
		4: world_4 = default_world
		5: world_5 = default_world

func delete_world_save(world_num: int) -> bool:
	if world_num < 1 or world_num > 5:
		print("Ошибка: Номер мира должен быть от 1 до 5")
		return false
	reset_world_to_default(world_num)
	var file_path = "user://world_" + str(world_num) + ".save"
	if not FileAccess.file_exists(file_path):
		print("Файл сохранения мира ", world_num, " не найден")
		return false
	var dir = DirAccess.open("user://")
	if dir:
		var error = dir.remove(file_path)
		if error == OK:
			print("Файл сохранения мира ", world_num, " успешно удален")
			return true
		else:
			print("Ошибка при удалении файла сохранения мира ", world_num, ": ", error)
			return false
	else:
		print("Ошибка при открытии директории user://")
		return false

func _input(event: InputEvent):
	if event.is_action_pressed("UI_fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
