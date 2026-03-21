extends Node3D

@export_multiline var textLabel_ru = ""

func _ready() -> void:
	$Label3D.text = textLabel_ru
