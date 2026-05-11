extends StaticBody3D

@export var smoke = false
@export var handle = false

func _ready() -> void:
	if !smoke:
		$MeshInstance3D2/smoke.queue_free()
	if !handle:
		$MeshInstance3D2.queue_free()
