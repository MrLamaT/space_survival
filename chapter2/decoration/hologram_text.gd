extends Node3D

@export_multiline var textLabel_ru = ""
@export_multiline var textLabel_en = ""

func _ready() -> void:
	var sprite = $Sprite3D
	var subviewport = $Sprite3D/SubViewport
	sprite.texture = subviewport.get_texture()
	if Global.game_settings["gui_settings"]["Language"] == "русский":
		$Sprite3D/SubViewport/Panel/RichTextLabel.text = textLabel_ru
	else:
		$Sprite3D/SubViewport/Panel/RichTextLabel.text = textLabel_en
