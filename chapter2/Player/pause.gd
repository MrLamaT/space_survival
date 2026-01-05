extends Panel

var player: CharacterBody3D

func toggle_setting(setting_key: String, display_text: String, button_node: Node) -> void:
	# Переключаем настройку
	Global.game_settings["gui_settings"][setting_key] = !Global.game_settings["gui_settings"][setting_key]
	
	# Обновляем текст через метод кнопки
	var state = "[ON]" if Global.game_settings["gui_settings"][setting_key] else "[OFF]"
	button_node.newLabel(display_text + " " + state)

func _on_button_coords_pressed() -> void:
	toggle_setting("coordinates", "Coords", $LabelButton2)
	$AudioStreamPlayer.play()

func _on_button_timer_pressed() -> void:
	toggle_setting("timer", "Timer", $LabelButton3)
	$AudioStreamPlayer.play()

func _on_button_fps_pressed() -> void:
	toggle_setting("fps", "FPS", $LabelButton)
	$AudioStreamPlayer.play()

func _on_button_main_pressed() -> void:
	if Global.game_settings["HP"] <= 5:
		player = get_tree().get_first_node_in_group("player")
		player.PlayerDeath(-10)
