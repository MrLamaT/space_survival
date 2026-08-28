extends Node3D

@export var PipeLeft = false
@export var PipeRight = false

func _ready() -> void:
	if !PipeLeft:
		$Pipe2.queue_free()
		$Pipe4.queue_free()
	if !PipeRight:
		$Pipe.queue_free()
		$Pipe3.queue_free()
