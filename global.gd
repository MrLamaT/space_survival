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
		"Autosave": true
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
	"debugging": false
}
var saved_portal_data: Dictionary = {}

func _ready():
	load_game_settings()

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

func save_settings():
	save_game_settings()
