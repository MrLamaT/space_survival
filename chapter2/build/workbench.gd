extends Area3D

var _secondary_color: Color

func _ready() -> void:
	ApplyingSkin()

func ApplyingSkin():
	_secondary_color = Color("82594e").darkened(0.1)
	$StaticBody/Sprite3D.modulate = _secondary_color

func trigger_interaction():
	var player = get_tree().get_first_node_in_group("player")
	player.openUI("workbenchRecipe")

func _on_mouse_entered() -> void:
	$StaticBody/Sprite3D.modulate = Color("ffffffff")
	$StaticBody/Sprite3D.shaded = false
	$StaticBody/Sprite3D/OmniLight3D.visible = true
	$StaticBody/Node3D/MeshInstance3D.visible = false
	$StaticBody/Node3D/MeshInstance3D2.visible = true
	$StaticBody/Node3D/CSGCombiner3D/box.visible = true
	$StaticBody/Node3D/OmniLight3D.visible = true
	

func _on_mouse_exited() -> void:
	$StaticBody/Sprite3D.modulate = _secondary_color
	$StaticBody/Sprite3D.shaded = true
	$StaticBody/Sprite3D/OmniLight3D.visible = false
	$StaticBody/Node3D/MeshInstance3D.visible = true
	$StaticBody/Node3D/MeshInstance3D2.visible = false
	$StaticBody/Node3D/CSGCombiner3D/box.visible = false
	$StaticBody/Node3D/OmniLight3D.visible = false
