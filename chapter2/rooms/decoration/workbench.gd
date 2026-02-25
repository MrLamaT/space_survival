extends Area3D

@export var _base_color: Color

var _secondary_color: Color

func _ready() -> void:
	ApplyingSkin()

func ApplyingSkin():
	var material = StandardMaterial3D.new()
	material.albedo_color = _base_color
	$StaticBody/MeshInstance3D.material_override = material
	_secondary_color = _base_color.darkened(0.3)
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
	$StaticBody/Node3D/CSGCombiner3D/AnimationPlayer.play("pole")

func _on_mouse_exited() -> void:
	$StaticBody/Sprite3D.modulate = _secondary_color
	$StaticBody/Sprite3D.shaded = true
	$StaticBody/Sprite3D/OmniLight3D.visible = false
	$StaticBody/Node3D/MeshInstance3D.visible = true
	$StaticBody/Node3D/MeshInstance3D2.visible = false
	$StaticBody/Node3D/CSGCombiner3D/AnimationPlayer.play("RESET")
