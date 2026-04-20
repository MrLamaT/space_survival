extends Area3D

func trigger_interaction():
	var player = get_tree().get_first_node_in_group("player")
	player.weapon_system.equip_weapon("Move")

func _on_mouse_entered() -> void:
	pass # Replace with function body.

func _on_mouse_exited() -> void:
	pass # Replace with function body.
