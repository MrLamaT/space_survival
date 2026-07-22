extends Area3D

var _secondary_color: Color

func _ready() -> void:
	_secondary_color = Color("82594e").darkened(0.1)
	get_node("../Sprite3D").modulate = _secondary_color

func trigger_interaction():
	var player = get_tree().get_first_node_in_group("player")
	player.openUI("building")

func _on_mouse_entered() -> void:
	get_node("../Sprite3D").modulate = Color("ffffffff")
	get_node("../Sprite3D").shaded = false
	get_node("../Sprite3D/OmniLight3D").visible = true
	get_node("../Node3D/MeshInstance3D").visible = false
	get_node("../Node3D/MeshInstance3D2").visible = true
	get_node("../Node3D/CSGCombiner3D/box").visible = true
	get_node("../Node3D/OmniLight3D").visible = true

func _on_mouse_exited() -> void:
	get_node("../Sprite3D").modulate = _secondary_color
	get_node("../Sprite3D").shaded = true
	get_node("../Sprite3D/OmniLight3D").visible = false
	get_node("../Node3D/MeshInstance3D").visible = true
	get_node("../Node3D/MeshInstance3D2").visible = false
	get_node("../Node3D/CSGCombiner3D/box").visible = false
	get_node("../Node3D/OmniLight3D").visible = false
