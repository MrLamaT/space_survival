extends Area3D

@export var chest: String

func trigger_interaction():
	var player = get_tree().get_first_node_in_group("player")
	player.open_inventory(chest, "storage")

func _on_mouse_entered() -> void:
	$Sprite3D.modulate = Color("ffffffff")
	$Sprite3D.shaded = false
	$Sprite3D/OmniLight3D.visible = true

func _on_mouse_exited() -> void:
	$Sprite3D.modulate = Color("402923")
	$Sprite3D.shaded = true
	$Sprite3D/OmniLight3D.visible = false
