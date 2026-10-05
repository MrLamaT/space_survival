extends Node2D

func _on_label_button_pressed(id: String) -> void:
	match id:
		"exit":
			save()
			SceneManager.load_scene_with_loading("res://game/rooms/main.tscn")
		"back":
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			Global.game_settings["UI"] = false
			queue_free()
		"checkpoint":
			var player = get_tree().get_first_node_in_group("player")
			player.respawn_player()
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			Global.game_settings["UI"] = false
			queue_free()
		"options":
			var player = get_tree().get_first_node_in_group("player")
			player.openUI("options")
			queue_free()
		"skin":
			var player = get_tree().get_first_node_in_group("player")
			player.openUI("skins")
			queue_free()
		"miss":
			var player = get_tree().get_first_node_in_group("player")
			player.openUI("planet")
			queue_free()

func save():
	Global.save(Global.game_settings["word"])
