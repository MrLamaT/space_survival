extends Node2D

@onready var vbox_container = $Panel/ScrollContainer/VBoxContainer
@onready var path_label = $Panel/path

const MUSIC_SLOT_SCENE = preload("res://UI/music/music_slot.tscn")
var current_slot = null

func _ready() -> void:
	var music_path = ProjectSettings.globalize_path("user://") + "music/"
	path_label.text = music_path
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("music"):
		dir.make_dir("music")
	load_music_files()
	Global.game_settings["music"] = ""
	var music_node = get_tree().get_first_node_in_group("music")
	music_node._check_and_play_custom_music()

func _on_path_text_changed(_new_text: String) -> void:
	path_label.text = ProjectSettings.globalize_path("user://") + "music/"

func _on_label_button_pressed(_id: String) -> void:
	load_music_files()

func load_music_files() -> void:
	for child in vbox_container.get_children():
		child.queue_free()
	var music_dir = DirAccess.open("user://music/")
	if not music_dir:
		print("Не удалось открыть папку с музыкой")
		return
	var files = music_dir.get_files()
	files.sort()
	for file in files:
		if file.to_lower().ends_with(".mp3"):
			var slot = MUSIC_SLOT_SCENE.instantiate()
			var file_name = file.get_basename()
			if slot.has_node("Panel/Label"):
				slot.get_node("Panel/Label").text = file_name
			load_cover(slot, file_name)
			slot.set_meta("file_path", "user://music/" + file)
			slot.set_meta("file_name", file)
			if slot.has_node("Panel/Button"):
				var button = slot.get_node("Panel/Button")
				button.pressed.connect(_on_slot_button_pressed.bind(slot))
			vbox_container.add_child(slot)
	current_slot = null

func load_cover(slot: Control, file_name: String) -> void:
	var cover_extensions = [".jpg", ".jpeg", ".png", ".webp"]
	var music_dir = "user://music/"
	var card = slot.get_node("Panel/card")
	for ext in cover_extensions:
		var cover_path = music_dir + file_name + ext
		if FileAccess.file_exists(cover_path):
			var image = Image.load_from_file(ProjectSettings.globalize_path(cover_path))
			if image:
				var texture = ImageTexture.create_from_image(image)
				card.texture = texture
				return  
	card.texture = preload("res://assets/icon/note.png")

func _on_slot_button_pressed(slot: Control) -> void:
	var music_node = get_tree().get_first_node_in_group("music")
	var file_path = slot.get_meta("file_path")
	if not file_path:
		print("Путь к файлу не найден")
		return
	var file_name = slot.get_meta("file_name")
	if not file_name:
		print("Имя файла не найдено")
		return
	if current_slot == slot:
		current_slot = null
		reset_slot_styles()
		Global.game_settings["music"] = ""
		music_node._check_and_play_custom_music()
		return
	reset_slot_styles()
	Global.game_settings["music"] = file_name
	current_slot = slot
	highlight_slot(slot)
	music_node._check_and_play_custom_music()

func highlight_slot(slot: Control) -> void:
	if slot.has_node("Panel"):
		var panel = slot.get_node("Panel")
		if panel is Panel:
			var style = StyleBoxFlat.new()
			style.bg_color = Color("800e21ff")
			style.border_width_left = 2
			style.border_width_right = 2
			style.border_width_top = 2
			style.border_width_bottom = 2
			style.border_color = Color(1, 1, 1, 1)
			panel.add_theme_stylebox_override("panel", style)

func reset_slot_styles() -> void:
	for child in vbox_container.get_children():
		if child.has_node("Panel"):
			var panel = child.get_node("Panel")
			if panel is Panel:
				var style = StyleBoxFlat.new()
				style.bg_color = Color("00000096")
				style.border_width_left = 1
				style.border_width_right = 1
				style.border_width_top = 1
				style.border_width_bottom = 1
				style.border_color = Color(1, 1, 1, 1)
				panel.add_theme_stylebox_override("panel", style)
