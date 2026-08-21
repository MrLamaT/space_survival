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
		$TextureRect.texture = preload("res://assets/icon/delete.png")
	if (level == -1 or level == -2) and world["mode"] != 1:
		visible = false
		

func _on_button_pressed() -> void:
	if $Label2.text != "Locked":
		var level_path = Global.level.get(level)
		if level_path != null:
			get_node("../../..").teleport(level_path)
		else:
			get_node("../../..").teleport(Global.level.get(1))
