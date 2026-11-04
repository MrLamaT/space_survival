extends Node3D

@export_multiline var textLabel_en = ""

func _ready() -> void:
	var sprite = $Sprite3D
	var subviewport = $Sprite3D/SubViewport
	sprite.texture = subviewport.get_texture()
	$Sprite3D/SubViewport/Panel/RichTextLabel.text = textLabel_en
