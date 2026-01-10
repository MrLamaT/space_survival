extends Node2D

func _on_label_button_pressed(id: String) -> void:
	match id:
		"exit":
			SceneManager.load_scene_with_loading("res://chapter2/rooms/main.tscn")
		"back":
			visible = false
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
