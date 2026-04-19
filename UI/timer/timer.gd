extends Node2D

var current_value: int = 0
var player: CharacterBody3D = null

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

func start_countdown() -> void:
	current_value = 120
	var world = Global.get_world(Global.game_settings.word)
	if "solar panels" in world["equipment"]:
		current_value = 180
	$Label.text = str(current_value)
	$Timer.start()
	visible = true

func _on_timer_timeout() -> void:
	current_value -= 1
	$Label.text = str(current_value)
	if current_value <= 0:
		if Global.game_settings["gui_settings"]["Language"] == "русский":
			player.warning("Соединение разорвано. Объект признан потерянным.")
		else:
			player.warning("Connection terminated. Asset designated as lost.")
		player.get_node("head/Camera3D/Teleport").kill()
		$Timer.stop()
		visible = false

func boost(boostTime):
	current_value += boostTime
