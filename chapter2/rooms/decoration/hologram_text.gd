extends Node3D

@export_multiline var textLabel_ru = ""
@export_multiline var textLabel_en = ""
@export var img: Texture

func _ready() -> void:
	if img:
		$Sprite3D/SubViewport/Panel/TextureRect.texture = img
	else:
		$Sprite3D/SubViewport/Panel/TextureRect.visible = false
		$Sprite3D/SubViewport/Panel/RichTextLabel.position.y = 50
	if Global.game_settings["gui_settings"]["Language"] == "русский":
		$Sprite3D/SubViewport/Panel/RichTextLabel.text = textLabel_ru
	else:
		$Sprite3D/SubViewport/Panel/RichTextLabel.text = textLabel_en
