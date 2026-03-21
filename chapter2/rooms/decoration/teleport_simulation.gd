extends StaticBody3D

@export var navigation_region: NavigationRegion3D
@export var is_exit: bool = false

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		if navigation_region:
			var target_marker = find_marker_in_region(navigation_region)
			if target_marker:
				body.global_position = target_marker.global_position

func find_marker_in_region(region: NavigationRegion3D) -> Node3D:
	var marker_name = "Exit" if is_exit else "Entry"
	for child in region.get_children():
		if child is Node3D and child.name == marker_name:
			return child
	for child in region.get_children():
		if child.is_in_group("teleport_markers"):
			if (is_exit and child.is_in_group("exit")) or (not is_exit and child.is_in_group("entry")):
				return child
	return null
