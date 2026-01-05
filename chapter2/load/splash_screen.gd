extends Control

func _ready():
	# Показываем сплэш-скрин
	await get_tree().create_timer(2.0).timeout 
	SceneManager.load_scene_with_loading("res://chapter2/rooms/main.tscn")
