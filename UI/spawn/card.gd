extends Control

@export var text = ""
@export var img: Texture
@export var color_img: Color = Color("ffffffff")
@export var type = ""
@export var target_node: Node = null

func _ready() -> void:
	$Panel/Label.text = text
	$Panel/card.texture = img
	$Panel/card.modulate = color_img

func _on_button_pressed() -> void:
	target_node.handle_card_pressed(type, text, color_img)
