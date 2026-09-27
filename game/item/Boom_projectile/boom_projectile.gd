extends Node3D

var KNOCKBACK_FORCE: float = 40.0

func shoot(_dir: Vector3, _spd: float):
	pass

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") or body.is_in_group("enemy"):
		var knockback_direction = (body.global_position - global_position).normalized()
		if body is CharacterBody3D:
			body.velocity.x = knockback_direction.x * KNOCKBACK_FORCE
			body.velocity.z = knockback_direction.z * KNOCKBACK_FORCE
			body.velocity.y = KNOCKBACK_FORCE * 0.25

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "boom":
		queue_free()
