extends Area3D

var water_check = false
var water_filter = preload("res://assets/shaders/filter/f_water.tres")

func _on_body_entered(body: Node3D) -> void:
	var filter = get_tree().get_first_node_in_group("filter")
	if body.is_in_group("player") and !filter.visible:
		water_check = true
		filter.visible = true
		filter.material_override = water_filter

func _on_body_exited(body: Node3D) -> void:
	var filter = get_tree().get_first_node_in_group("filter")
	if body.is_in_group("player") and water_check:
		filter.visible = false
