extends Node2D

@onready var texture_sprite: Sprite2D = $Panel/Sprite2D
var item_files: Array = []
var current_index: int = 0

func _ready() -> void:
	load_item_files()

func load_item_files() -> void:
	# Получаем список файлов через функционал ResourceLoader
	var items = get_available_items()
	if items.size() > 0:
		item_files = items
		item_files.sort()
		current_index = 0
		display_current_item()
	else:
		print("В папке нет PNG файлов")

func get_available_items() -> Array:
	var items = []
	var dir = DirAccess.open("res://assets/item/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			# Проверяем оба варианта (для редактора и для экспорта)
			if file_name.ends_with(".png") and not dir.current_is_dir():
				items.append(file_name)
			elif file_name.ends_with(".png.import") and not dir.current_is_dir():
				# Убираем .import для получения оригинального имени
				items.append(file_name.replace(".png.import", ".png"))
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		# Если не можем открыть директорию, пробуем другой подход
		print("Не удалось открыть директорию, пробуем альтернативный метод...")
		# Альтернативный метод: проверяем существование файлов через ResourceLoader
		check_items_via_resourceloader()
	return items

func check_items_via_resourceloader() -> void:
	# Этот метод вызывается, если не удалось открыть директорию
	# Пробуем найти предметы по известным именам или через пресеты
	# Здесь можно добавить логику для поиска предметов, если у вас есть список известных предметов
	pass

func display_current_item() -> void:
	if item_files.size() > 0:
		var current_file = item_files[current_index]
		# Используем ResourceLoader.exists() как в инвентаре
		var icon_path = "res://assets/item/" + current_file
		if ResourceLoader.exists(icon_path):
			var texture = load(icon_path)
			if texture:
				texture_sprite.texture = texture
				print("Текущий предмет: ", current_file)
			else:
				print("Ошибка загрузки текстуры: ", icon_path)
		else:
			print("Ресурс не найден: ", icon_path)

func clean_item_name(filename: String) -> String:
	# Убираем расширение .png
	var name_without_ext = filename.replace(".png", "")
	# Заменяем _ на пробел
	return name_without_ext.replace("_", " ")

func _on_label_button_pressed(id: String) -> void:
	match id:
		"next":
			if item_files.size() > 0:
				current_index = (current_index + 1) % item_files.size()
				display_current_item()
		"give":
			if item_files.size() > 0:
				var current_file = item_files[current_index]
				var cleaned_name = clean_item_name(current_file)
				
				var world = Global.get_world(Global.game_settings.word)
				if world and world.has("inventory"):
					world["inventory"]["inventory"].append(cleaned_name)
					print("Добавлено в инвентарь: ", cleaned_name)
				else:
					print("Ошибка: структура world или inventory не найдена")
		
		"previous":
			if item_files.size() > 0:
				current_index = (current_index - 1 + item_files.size()) % item_files.size()
				display_current_item()
