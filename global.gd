extends Node

var world_1: Dictionary = { 
	"name": "[NEW GAME 1]",
	"mode": 0,
	"stage": 0
}

var world_2: Dictionary = { 
	"name": "[NEW GAME 2]",
	"mode": 0,
	"stage": 0
}

var world_3: Dictionary = { 
	"name": "[NEW GAME 3]",
	"mode": 0,
	"stage": 0
}

var world_4: Dictionary = { 
	"name": "[NEW GAME 4]",
	"mode": 0,
	"stage": 0
}

var world_5: Dictionary = { 
	"name": "[NEW GAME 5]",
	"mode": 0,
	"stage": 0
}

var game_settings: Dictionary = {
	"Skin": 0,
	"Enemy": true,
	"gui_settings": {
		"Coords": false,
		"FPS": false,
		"Autosave": true,
		"Language": "English"
	},
	"CanStandUp": true,
	"CanThrowItem": true,
	"GodMod": false,
	"Item": "",
	"HP": 100,
	"nails_cartridge": 8,
	"shock_cartridge": 2,
	"IsDying": false,
	"ThrownCamera": null,
	"can_jump": true,
	"affected_by_gravity": true,
	"FloatHeight": 0,
	"word": 0,
	"debugging": false,
}
var saved_portal_data: Dictionary = {}

func _ready():
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

func load(world_num: int = 0):
	load_settings(world_num)
