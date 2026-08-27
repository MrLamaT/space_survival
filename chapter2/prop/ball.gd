extends RigidBody3D

@export var kick_force := 20.0        # Базовая сила удара

func _on_area_3d_body_entered(body: Node):
	if body.is_in_group("player"):
		kick_ball(body)

func kick_ball(player_in_area):
	var player_speed = player_in_area.velocity.length()
	var speed_multiplier = 1.0 + player_speed * 0.15
	var final_force = kick_force * speed_multiplier
	var direction = (global_position - player_in_area.global_position).normalized()
	direction.y *= 0.5
	var impulse = direction * final_force
	apply_central_impulse(impulse)
	var spin_axis = Vector3(
		randf_range(-1, 1),
		randf_range(-1, 1),
		randf_range(-1, 1)
	).normalized()
	var spin_power = 3.0 + player_speed * 0.5
	apply_torque_impulse(spin_axis * spin_power)
