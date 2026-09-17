extends Control

var world = Global.get_world(Global.game_settings.word)

@export var text = ""
@export var img: Texture
@export var Gnode: Node = null
@export var planet_node: Node = null
@export var min_level = 1
@export var max_level = 1

func _ready() -> void:
	$Panel/Label.text = text
	$Panel/card.texture = img
	if !img:
		$Panel/card.texture = preload("res://assets/icon/delete.png")
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
	Gnode.get_node("Panel/LabelButton").visible = true
	Gnode.get_node("Panel/ScrollContainer").visible = false
	planet_node.visible = true
	Gnode.get_node("Sprite2D").texture = img
	Gnode.get_node("Panel/Id").text = text
	Gnode.get_node("Sprite2D").visible = true
	Gnode.get_node("Panel/Id").visible = true
