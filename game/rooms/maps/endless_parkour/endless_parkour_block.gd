extends StaticBody3D

var has_copied = false

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and not has_copied:
		has_copied = true
		var new_scene = self.duplicate()
		var random_x = (1.0 if randf() > 0.5 else -1.0) * randf_range(1.0, 8.0)
		var random_z = (1.0 if randf() > 0.5 else -1.0) * randf_range(1.0, 8.0)
		var random_y = randf_range(1.0, 2.0)
		new_scene.position = self.position + Vector3(random_x, random_y, random_z)
		new_scene.add_to_group("endless_parkour_block")
		change_materials(new_scene)
		get_parent().add_child(new_scene)

func change_materials(node: Node) -> void:
	var red_material = StandardMaterial3D.new()
	red_material.albedo_color = Color.RED
	var white_material = StandardMaterial3D.new()
	white_material.albedo_color = Color.GREEN
	node.get_node("MeshInstance3D").material_override = red_material
	node.get_node("AudioStreamPlayer3D").pitch_scale = randf_range(0.8, 1.2)
	$MeshInstance3D.material_override = white_material
