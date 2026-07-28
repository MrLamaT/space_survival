extends Area3D

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		body.apply_poison(3)

func _on_timer_timeout() -> void:
	queue_free()
