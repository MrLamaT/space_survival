extends Node3D

@export_multiline var textLabel_ru = ""
@export_multiline var textLabel_en = ""
@export var icon = true

func _ready() -> void:
	if Global.game_settings["gui_settings"]["Language"] == "русский":
		$Label3D.text = textLabel_ru
	else:
		$Label3D.text = textLabel_en
	if !icon:
		$Sprite3D.visible = false
