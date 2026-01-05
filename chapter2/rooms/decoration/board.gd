extends Node3D

@onready var mesh_instance = $StaticBody/paintings

# Добавляем поле ввода для имени конкретной картины
@export var specific_painting: String = ""  # Имя файла картины (например: "mona_lisa.png")

func _ready():
	# Получаем список файлов из папки с картинами
	var paintings_path = "res://assets/paintings/"
	var image_files = _get_image_files(paintings_path)
	
	if image_files.size() > 0:
		var selected_texture
		
		# Если указана конкретная картина, пытаемся загрузить её
		if specific_painting != "":
			var specific_path = paintings_path.path_join(specific_painting)
			if ResourceLoader.exists(specific_path):
				selected_texture = load(specific_path)
				if not selected_texture:
					push_warning("Не удалось загрузить указанную картину: " + specific_painting + ". Используется случайная.")
			else:
				push_warning("Указанная картина не найдена: " + specific_painting + ". Используется случайная.")
		
		# Если конкретная картина не указана или не найдена, выбираем случайную
		if not selected_texture:
			selected_texture = load(image_files.pick_random())
		
		if selected_texture:
			# Создаем QuadMesh
			var quad_mesh = QuadMesh.new()
			quad_mesh.size = Vector2(1.0, 1.0)  # Добавляем размер
			
			# Создаем и настраиваем материал
			var material = StandardMaterial3D.new()
			material.albedo_texture = selected_texture
			material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
			material.cull_mode = BaseMaterial3D.CULL_DISABLED
			material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			
			quad_mesh.material = material
			mesh_instance.mesh = quad_mesh
		else:
			push_error("Не удалось загрузить текстуру")
	else:
		push_error("Не найдено изображений в папке: " + paintings_path)

# Функция для получения списка изображений
func _get_image_files(path: String) -> Array[String]:
	var files: Array[String] = []
	var dir = DirAccess.open(path)
	
	if dir:
		var file_names = dir.get_files()
		for file_name in file_names:
			if file_name.ends_with(".png.import"):
				var cleaned = file_name.replace(".png.import", ".png")
				files.append(path.path_join(cleaned))
	else:
		print("Failed to open directory")
	
	print("Total image files: ", files.size())
	return files
