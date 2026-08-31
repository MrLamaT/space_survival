extends Node2D

@export var typing_speed: float = 0.025

var skip_typing: bool = false
var is_typing: bool = false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_rich_text_label_meta_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))

func _on_label_button_pressed(id: String) -> void:
	match id:
		"exit":
			save()
			SceneManager.load_scene_with_loading("res://game/rooms/main.tscn")

func save():
	Global.save(Global.game_settings["word"])
