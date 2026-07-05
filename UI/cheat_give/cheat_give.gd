extends Node2D

@onready var texture_sprite: Sprite2D = $Panel/Sprite2D
var item_textures: Array = []
var current_index: int = 0

func _ready() -> void:
	load_item_files()

func load_item_files() -> void:
	item_textures = [
		"res://assets/item/coal.png",
		"res://assets/item/copper.png",
		"res://assets/item/copper_cable.png",
		"res://assets/item/glass_panel.png",
		"res://assets/item/iron.png",
		"res://assets/item/iron_plate.png",
		"res://assets/item/MATiron.png",
		"res://assets/item/quartz.png",
		"res://assets/item/schematic.png",
		"res://assets/item/sercilist.png"
	]
	current_index = 0
	display_current_item()

func get_item_name_from_path(path: String) -> String:
	var Iname = path.replace("res://assets/item/", "").replace(".png", "")
	return Iname.replace("_", " ")

func display_current_item() -> void:
	if item_textures.size() > 0:
		var current_texture_path = item_textures[current_index]
		if ResourceLoader.exists(current_texture_path):
			var texture = load(current_texture_path)
			if texture:
				texture_sprite.texture = texture
				print("Текущий предмет: ", get_item_name_from_path(current_texture_path))
			else:
				print("Ошибка загрузки текстуры: ", current_texture_path)
		else:
			print("Ресурс не найден: ", current_texture_path)

func _on_label_button_pressed(id: String) -> void:
	match id:
		"next":
			if item_textures.size() > 0:
				current_index = (current_index + 1) % item_textures.size()
				display_current_item()
		"give":
			if item_textures.size() > 0:
				var current_texture_path = item_textures[current_index]
				var item_name = get_item_name_from_path(current_texture_path)
				
				var world = Global.get_world(Global.game_settings.word)
				if world and world.has("inventory"):
					world["inventory"]["inventory"].append(item_name)
					print("Добавлено в инвентарь: ", item_name)
				else:
					print("Ошибка: структура world или inventory не найдена")
		"previous":
			if item_textures.size() > 0:
				current_index = (current_index - 1 + item_textures.size()) % item_textures.size()
				display_current_item()
