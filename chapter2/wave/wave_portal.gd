extends MeshInstance3D

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "portal":
		queue_free()
