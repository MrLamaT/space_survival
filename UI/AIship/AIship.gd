extends Node2D

var system_color := Color("#faff68")
var user_color := Color("00ef00")
var error_color := Color("ff0000")

@onready var chat_panel = $Panel
@onready var chat_text = $Panel/RichTextLabel

var player: CharacterBody3D
var world = Global.get_world(Global.game_settings.word)

func _ready():
	SystemPrint("The system is running")
	player = get_tree().get_first_node_in_group("player")

func SystemPrint(text: String):
	chat_text.push_color(system_color)
	chat_text.add_text(" SYSTEM: " + text + "\n")
	chat_text.pop()

func ErrorPrint(text: String):
	chat_text.push_color(error_color)
	chat_text.add_text(" ERROR: " + text + "\n")
	chat_text.pop()

func UserPrint(text: String):
	chat_text.push_color(user_color)
	chat_text.add_text(" YOU: " + text + "\n")
	chat_text.pop()
