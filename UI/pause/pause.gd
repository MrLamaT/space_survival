extends Node2D

func _on_label_button_pressed(id: String) -> void:
	match id:
		"exit":
			save()
			Global.close_ui_and_resume_game(self)
			SceneManager.load_scene_with_loading("res://game/rooms/main.tscn")
		"back":
			Global.close_ui_and_resume_game(self)
		"checkpoint":
			var player = get_tree().get_first_node_in_group("player")
			player.respawn_player()
			Global.close_ui_and_resume_game(self)
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
	Global.save(Global.game_settings["world"])
