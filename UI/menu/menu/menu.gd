extends Node2D

func _on_label_button_pressed(id: String) -> void:
	match id:
		"play":
			_start_selected_game()
		"options":
			visible = false
			get_parent().get_node("options").visible = true
		"quit":
			get_tree().quit()

func _start_selected_game() -> void:
	var world_index := int(Global.game_settings["world"])
	var world_data := Global.get_world(world_index)
	if int(world_data["level"]) == 0:
		var level_path: String = Global.level.get(0, Global.level[1])
		SceneManager.load_scene_with_loading(level_path)
	else:
		SceneManager.load_scene_with_loading("res://UI/planet/planet.tscn")
