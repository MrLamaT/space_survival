extends Node2D

func _on_label_button_pressed(id: String) -> void:
	Global.game_settings["summon"]["enemyTags"] = id
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Global.game_settings["UI"] = false
	queue_free()
