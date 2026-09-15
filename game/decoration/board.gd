extends Node3D

@export var specific_painting: Texture2D = null

func _ready():
	$Sprite3D.texture = specific_painting
