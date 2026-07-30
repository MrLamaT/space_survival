extends Node3D

@export_multiline var textLabel_ru = ""
@export_multiline var textLabel_en = ""

func _ready() -> void:
	if Global.game_settings["gui_settings"]["Language"] == "русский":
		$Sprite3D/SubViewport/Panel/RichTextLabel.text = textLabel_ru
	else:
		$Sprite3D/SubViewport/Panel/RichTextLabel.text = textLabel_en
