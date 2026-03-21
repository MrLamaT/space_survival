extends Control

var world = Global.get_world(Global.game_settings.word)

@export var nameLevel = "1-1: RoP-856"
@export var img: Texture
@export var level = 1

func  _ready() -> void:
	$Label.text = nameLevel
	$TextureRect.texture = img
	if world["level"] > level:
		$Label2.modulate = Color("00ff00")
		$Label2.text = "Completed"
	elif world["level"] == level:
		$Label2.modulate = Color("ffffffff")
		$Label2.text = "Available"
	else:
		$Label2.modulate = Color("ff0000")
		$Label2.text = "Locked"
		$TextureRect.texture = preload("res://assets/delete.png")

func _on_button_pressed() -> void:
	get_node("../../..").teleport("res://chapter2/rooms/maps/RoP/RoP_1.tscn")
