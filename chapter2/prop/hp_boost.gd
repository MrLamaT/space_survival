extends Area3D

var _secondary_color: Color

func _ready() -> void:
	if has_node("../Sprite3D2"):
		_secondary_color = Color("ffffffff").darkened(0.1)
		get_node("../Sprite3D2").modulate = _secondary_color
		get_node("../Sprite3D3").modulate = _secondary_color

func trigger_interaction():
	if get_node("../GPUParticles3D").emitting:
		get_node("../GPUParticles3D").emitting = false
		get_node("../AudioStreamPlayer3D").play()
		get_node("../Sprite3D").modulate = Color("808080")
		remove_from_group("interactive_objects")
		var player = get_tree().get_first_node_in_group("player")
		player.HP(-100)
		Global.game_settings["checkpoint"] = player.global_position

func _on_mouse_entered() -> void:
	if has_node("../Sprite3D2"):
		get_node("../Sprite3D2").modulate = Color("ffffffff")
		get_node("../Sprite3D2").shaded = false
		get_node("../Sprite3D3").modulate = Color("ffffffff")
		get_node("../Sprite3D3").shaded = false

func _on_mouse_exited() -> void:
	if has_node("../Sprite3D2"):
		get_node("../Sprite3D2").modulate = _secondary_color
		get_node("../Sprite3D2").shaded = true
		get_node("../Sprite3D3").modulate = _secondary_color
		get_node("../Sprite3D3").shaded = true
