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
	$AnimationPlayer.play("logo")
	if MessageID == 1:
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
	if MessageID == 2:
		if Global.game_settings["gui_settings"]["Language"] == "русский":
			chat_text.text = "Тема: Охота за серцилистом.

Цитадель всё выгребла из шахт. Серцилиста тут нет… но мы нашли их старую базу. Оборудование, корпуса, даже трубы — всё из этого проклятого металла.
Цена на Кольце за килограмм… мы можем уйти с этого камня богачами. Если хватит духу.
Проблема: Внизу, в старых выработках, гнездо скатов. Эти твари размножились, как крысы. Каждый раз, когда мы спускаемся за деталью, кто-то не возвращается. Ещё пара рейсов, и мы сваливаем."
		else:
			chat_text.text = "Subject: Serсilist Scavenging.

The Citadel has scraped everything out of the mines. There's no Sericilite here… but we found their old base. The equipment, the hulls, even the pipes—everything is made of that damned metal.
The price per kilo on the Ring… we could leave this rock as rich men. If we've got the nerve.
Problem is: down in the old workings, there's a ray nest. Those bastards have bred like rats. Every time we go down for a part, someone doesn't come back. A couple more runs, and we're out of here."
