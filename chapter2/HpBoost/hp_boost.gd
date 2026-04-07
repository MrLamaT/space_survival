extends Area3D

func trigger_interaction():
	if $GPUParticles3D.emitting:
		$GPUParticles3D.emitting = false
		$AudioStreamPlayer3D.play()
		$Sprite3D.modulate = Color("808080")
		var player = get_tree().get_first_node_in_group("player")
		player.HP(-100)

func _on_mouse_entered() -> void:
	pass # Replace with function body.

func _on_mouse_exited() -> void:
	pass # Replace with function body.
