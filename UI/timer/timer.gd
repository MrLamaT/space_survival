extends Node2D

var current_value: int = 0
var player: CharacterBody3D = null

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

func start_countdown(initial_value: int) -> void:
	current_value = initial_value
	$Label.text = str(current_value)
	$Timer.start()
	visible = true

func _on_timer_timeout() -> void:
	current_value -= 1
	$Label.text = str(current_value)
	if current_value == 60:
		if Global.game_settings["gui_settings"]["Language"] == "русский":
			player.warning("Схлопывание портала через 60 секунд.\nРекомендован возврат.")
		else:
			player.warning("Portal collapse in 60 seconds.\nRecommended return.")
	if current_value == 30:
		if Global.game_settings["gui_settings"]["Language"] == "русский":
			player.warning("Критично: портал нестабилен.\nСхлопывание через 30 секунд.")
		else:
			player.warning("Critical: Portal unstable.\n30 seconds to collapse.")
	if current_value == 10:
		if Global.game_settings["gui_settings"]["Language"] == "русский":
			player.warning("АВАРИЯ: Схлопывание портала неминуемо! 10!")
		else:
			player.warning("EMERGENCY: Portal collapse imminent! 10!")
	if current_value <= 0:
		if Global.game_settings["gui_settings"]["Language"] == "русский":
			player.warning("Соединение разорвано. Объект признан потерянным.")
		else:
			player.warning("Connection terminated. Asset designated as lost.")
		player.get_node("head/Camera3D/Teleport").kill()
		$Timer.stop()
		visible = false
