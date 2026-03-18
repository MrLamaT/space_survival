extends Node2D

func _on_label_button_pressed(id: String) -> void:
	match id:
		"exit":
			save()
			SceneManager.load_scene_with_loading("res://chapter2/rooms/main.tscn")
		"back":
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			Global.game_settings["UI"] = false
			queue_free()

func save():
	Global.save(Global.game_settings["word"])
