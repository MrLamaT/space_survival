extends RigidBody3D

var _secondary_color: Color

func _ready() -> void:
	_secondary_color = Color("ffffffff").darkened(0.1)
	$Sprite3D.modulate = _secondary_color

func trigger_interaction():
	var player = get_tree().get_first_node_in_group("player")
	player.openUI("skins")

func _on_mouse_entered() -> void:
	$Sprite3D.modulate = Color("ffffffff")
	$Sprite3D.shaded = false
	$Node3D/MeshInstance3D.visible = false
	$Node3D/MeshInstance3D2.visible = true
	$Node3D/CSGCombiner3D/box.visible = true
	$Node3D/OmniLight3D.visible = true

func _on_mouse_exited() -> void:
	$Sprite3D.modulate = _secondary_color
	$Sprite3D.shaded = true
	$Node3D/MeshInstance3D.visible = true
	$Node3D/MeshInstance3D2.visible = false
	$Node3D/CSGCombiner3D/box.visible = false
	$Node3D/OmniLight3D.visible = false
