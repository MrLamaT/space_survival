extends Node3D

@export var light = true

func _ready() -> void:
	if !light:
		$Light.queue_free()
