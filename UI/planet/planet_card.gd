extends Control

var world = Global.get_world(Global.game_settings.word)

@export var text = ""
@export var img: Texture
@export var planet_node: Node = null
@export var planet_sprite: Node = null
@export var planet_label: Node = null
@export var map_node: Node = null
@export var min_level = 1
@export var max_level = 1

func _ready() -> void:
	$Panel/Label.text = text
	$Panel/card.texture = img
	if world["level"] > max_level:
		$Panel/Label2.modulate = Color("00ff00")
		$Panel/Label2.text = "Completed"
	elif world["level"] < min_level:
		$Panel/Label2.modulate = Color("ff0000")
		$Panel/Label2.text = "Locked"
	else:
		$Panel/Label2.modulate = Color("ffffffff")
		$Panel/Label2.text = "Available"

func _on_button_pressed() -> void:
	if $Panel/Label2.text == "Locked":
		$AnimationPlayer.play("block")
		return
	map_node.visible = false
	planet_node.visible = true
	planet_sprite.texture = img
	planet_label.text = text
	planet_sprite.visible = true
	planet_label.visible = true
