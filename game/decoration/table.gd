extends Node3D

@export var delete = false

func _ready() -> void:
	if delete:
		$InvisibleTrigger.queue_free()
