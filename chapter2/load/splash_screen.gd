extends Control

@onready var textures: Array[Texture2D] = [
	preload("res://assets/level/planet1_1.png"),
	preload("res://assets/level/planet1_2.png")
]

func _ready():
	await get_tree().process_frame 
	if textures.size() > 0:
		var random_texture = textures[randi() % textures.size()]
		$Panel/TextureRect.texture = random_texture
	await get_tree().create_timer(2.0).timeout 
	SceneManager.load_scene_with_loading("res://chapter2/rooms/main.tscn")
