extends "res://game/rooms/BaseMaps.gd"

func _on_area_3d_body_entered(_body: Node3D) -> void:
	var blocks = get_tree().get_nodes_in_group("endless_parkour_block")
	for block in blocks:
		block.queue_free()
	$NavigationRegion3D/StaticBody3D.has_copied = false
