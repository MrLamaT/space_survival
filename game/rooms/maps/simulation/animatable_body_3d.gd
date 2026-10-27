extends AnimatableBody3D

@export var travel_offset: Vector3 = Vector3(4.0, 0.0, 0.0)
@export var cycle_duration: float = 4.0

@onready var start_position: Vector3 = position

var movement_time: float = 0.0


# Обновляет движение платформы в физическом кадре
func _physics_process(delta):
	_update_platform_position(delta)


# Плавно перемещает платформу между начальной и конечной точками
func _update_platform_position(delta: float) -> void:
	var duration: float = maxf(cycle_duration, 0.1)
	movement_time = fmod(movement_time + delta, duration)

	var phase: float = movement_time / duration
	var progress: float = (1.0 - cos(phase * TAU)) * 0.5

	position = start_position + travel_offset * progress
