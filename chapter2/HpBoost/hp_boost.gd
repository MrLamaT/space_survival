extends Area3D

var _secondary_color: Color

func _ready() -> void:
	if has_node("Sprite3D2"):
		_secondary_color = Color("c0c6cd").darkened(0.1)
		$Sprite3D2.modulate = _secondary_color
		$Sprite3D3.modulate = _secondary_color

func trigger_interaction():
	if $GPUParticles3D.emitting:
		$GPUParticles3D.emitting = false
		$AudioStreamPlayer3D.play()
		$Sprite3D.modulate = Color("808080")
		remove_from_group("interactive_objects")
		var player = get_tree().get_first_node_in_group("player")
		player.HP(-100)

func _on_mouse_entered() -> void:
	if has_node("Sprite3D2"):
		$Sprite3D2.modulate = Color("ffffffff")
		$Sprite3D2.shaded = false
		$Sprite3D2/OmniLight3D.visible = true
		$Sprite3D3.modulate = Color("ffffffff")
		$Sprite3D3.shaded = false
		$Sprite3D3/OmniLight3D.visible = true

func _on_mouse_exited() -> void:
	if has_node("Sprite3D2"):
		$Sprite3D2.modulate = _secondary_color
		$Sprite3D2.shaded = true
		$Sprite3D2/OmniLight3D.visible = false
		$Sprite3D3.modulate = _secondary_color
		$Sprite3D3.shaded = true
		$Sprite3D3/OmniLight3D.visible = false
