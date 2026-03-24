extends Node2D

var system_color := Color("#faff68")
var user_color := Color("00ef00")
var error_color := Color("ff0000")

@onready var chat_panel = $Panel
@onready var chat_text = $Panel/RichTextLabel

var player: CharacterBody3D
var world = Global.get_world(Global.game_settings.word)
var MessageID = 1

func _ready():
	player = get_tree().get_first_node_in_group("player")
	print("MessagesID:", MessageID)
	if MessageID == 0:
		$AnimationPlayer.play("logo")
		if Global.game_settings["gui_settings"]["Language"] == "русский":
			chat_text.text = "тестовый текст. 
--. ..- .- .-. -.. .. .- -. / .-.. --- ...- . ... / -.-- --- ..- / # ...-- .-.-.-"
		else:
			chat_text.text = "test text. 
--. ..- .- .-. -.. .. .- -. / .-.. --- ...- . ... / -.-- --- ..- / # ...-- .-.-.-"
	if MessageID == 1:
		$AnimationPlayer.play("logo")
		if Global.game_settings["gui_settings"]["Language"] == "русский":
			chat_text.text = "Тема: Базовая Калибровка.

Добро пожаловать на борт. Я — Опекун. Искусственный Интеллект, разработанный инженерами Цитадели для персонализированного сопровождения и мониторинга состояния систем.
биометрические показатели указывают на замешательство. Это предсказуемо.
Корабль в критическом состоянии после скачка через аномалию. Бездействие приведёт к смерти в течение 72 часов.
Хорошая новость: Портал Скачка работает. Задача: найти ресурсы и вернуть энергию на борт. Хотя бы 10%."
		else:
			chat_text.text = "Subject: Basic Calibration.

Welcome aboard. I am the Caretaker — an Artificial Intelligence developed by the Citadel's engineers for personalized accompaniment and system status monitoring.
Biometric readings indicate confusion. This is predictable.
The ship is in critical condition after jumping through an anomaly. Inaction will lead to death within 72 hours.
The good news: The Jump Gate is operational. Mission objective: locate resources and restore power to the vessel. At least 10%."
