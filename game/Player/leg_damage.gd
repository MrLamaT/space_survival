extends Area3D

func _on_body_entered(body: Node3D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(10)
		if body is CharacterBody3D:
			body.velocity.y = 7.5
			var horizontal_force = Vector3(
				randf_range(-2.0, 2.0),
				0,
				randf_range(-2.0, 2.0)
			) * 0.5
			body.velocity += horizontal_force
