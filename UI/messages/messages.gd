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
	if MessageID == 2:
		if Global.game_settings["gui_settings"]["Language"] == "русский":
			chat_text.text = "Тема: УРОВЕНЬ ЗАРАЖЕНИЯ ФАНТОМАМИ.

[СИСТЕМНОЕ СООБЩЕНИЕ]
ПРЕДУПРЕЖДЕНИЕ: КРИТИЧЕСКИЙ УРОВЕНЬ ЗАРАЖЕНИЯ ФАНТОМАМИ.
Количество активных полей подавления снизилось на 94.7% с момента последнего техобслуживания. Отказ цепной реакции."
		else:
			chat_text.text = "Subject: PHANTOM INFESTATION LEVEL.

[SYSTEM BROADCAST]
WARNING: PHANTOM INFESTATION LEVEL: CRITICAL.
Active suppression field generators have failed by 94.7% since last maintenance. Cascade failure event."
	if MessageID == 3:
		if Global.game_settings["gui_settings"]["Language"] == "русский":
			chat_text.text = "Тема: неэффективность клонирования.

Я снова пересматриваю спецификации серии «Стандартный клон-солдат». И я в замешательстве.
Зачем нам это? Зачем оставлять в матрице страх, жалость, гнев? Это дефекты, а не функции.
Идеальный солдат должен быть эффективным. Бесстрашный не убежит. Беспощадный не задумается. Бесчувственный не предаст. А наши клоны... они сомневаются. Они отказываются стрелять по гражданским. Они паникуют под обстрелом. Они носятся спасать раненых, снижая боевую эффективность подразделения.
Кто вообще решил, что армии нужны «человеческие» качества? Нам нужны био-машины, готовые выполнить приказ любой ценой. Всё остальное — просто лишняя трата биомассы. Исправьте это в следующей ревизии."
		else:
			chat_text.text = "Subject: cloning inefficiencies.

I am reviewing the specifications for the «Standard Clone Soldier» series again. And I am confused.
Why do we need this? Why keep fear, pity, or anger in the matrix? These are defects, not features.
The perfect soldier should be efficient. A fearless one won't flee. A ruthless one won't hesitate. An apathetic one won't defect. But our clones... they doubt. They refuse to fire on civilians. They panic under fire. They waste time rescuing the wounded, reducing unit combat effectiveness.
Who exactly decided that armies need «human» qualities? We need bio-machines, ready to follow orders at any cost. Everything else is just a waste of biomass. Fix this in the next revision."
	if MessageID == 4:
		if Global.game_settings["gui_settings"]["Language"] == "русский":
			chat_text.text = "Тема: неэффективность клонирования — ответ.

Инспектор, ваш лог попал ко мне на стол. С позволения Совета, я вынужден ответить.
Машина без эмоций начнет глючить от первой же нестыковки в приказе. А наш «несовершенный» клон... он испугается, но полезет спасать товарища. Он разозлится и уничтожит врага, который умнее его. Он пожалеет ребенка на руинах и защитит его, даже если это не в приказе."
		else:
			chat_text.text = "Subject: cloning inefficiencies — answer.

Inspector, your log landed on my desk. With the Council's indulgence, I am compelled to respond.
An emotionless machine will start glitching at the first contradiction in its orders. But our «imperfect» clone... he will be afraid, but he will still jump in to save a comrade. He will get angry and destroy an enemy that is smarter than him. He will pity a child in the ruins and protect him, even if the order says to ignore him."
