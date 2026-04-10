extends Node3D

@export_multiline var textLabel_ru = ""
@export_multiline var textLabel_en = ""

func _ready() -> void:
	if Global.game_settings["gui_settings"]["Language"] == "русский":
		$Label3D.text = textLabel_ru
	else:
		$Label3D.text = textLabel_en
