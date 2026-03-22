extends Node3D

var damage: int = 20
var lifetime: float = 0.2
var timer: float = 0.0

func shoot(_dir: Vector3, _spd: float):
	timer = 0.0

func _physics_process(delta):
	timer += delta
	if timer >= lifetime:
		queue_free()

func _on_area_3d_body_entered(body: Node3D) -> void:
	print(body)
	if body.has_method("take_damage"):
		body.take_damage(damage)
