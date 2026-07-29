extends Area3D

@export var type = "enemy"

func _on_body_entered(body: Node3D) -> void:
	if type == "enemy":
		if body.is_in_group("enemy"):
			body.take_damage(12)
	else:
		if body.is_in_group("player"):
			body.apply_poison(3)

func _on_timer_timeout() -> void:
	queue_free()
