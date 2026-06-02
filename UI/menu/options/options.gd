extends Node2D

func _ready() -> void:
	$Panel/VBoxContainer/language.text = "Language [" + Global.game_settings["gui_settings"]["Language"] + "]"

func _on_label_button_pressed(id: String) -> void:
	match id:
		"Autosave", "Coords", "FPS", "Speed":
			Global.game_settings["gui_settings"][id] = !Global.game_settings["gui_settings"][id]
			var button_node = get_node("Panel/VBoxContainer/" + id)
			if Global.game_settings["gui_settings"][id]:
				button_node.text = id + " [ON]"
			else:
				button_node.text = id + " [OFF]"
			$beep.play()
			Global.save(0)
		"Language":
			if Global.game_settings["gui_settings"]["Language"] == "English":
				Global.game_settings["gui_settings"]["Language"] = "русский"
			else:
				Global.game_settings["gui_settings"]["Language"] = "English"
			$Panel/VBoxContainer/language.text = "Language [" + Global.game_settings["gui_settings"]["Language"] + "]"
			$beep.play()
			Global.save(0)
		"BACK":
			visible = false
			get_parent().get_node("menu").visible = true
			$beep.play()
