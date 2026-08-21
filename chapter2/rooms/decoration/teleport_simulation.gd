extends StaticBody3D

@export var exit: Node3D

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and exit:
		var target_marker = exit.get_node("Entry")
		if target_marker:
			body.global_position = target_marker.global_position
