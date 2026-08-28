extends Area3D

var _secondary_color: Color

func _ready() -> void:
	await get_tree().process_frame
	var music_node = get_tree().get_first_node_in_group("music")
	music_node._check_and_play_custom_music()
	_secondary_color = Color("ffffffff").darkened(0.1)
	get_node("../Sprite3D").modulate = _secondary_color
	get_node("../Sprite3D2").modulate = _secondary_color

func trigger_interaction():
	var player = get_tree().get_first_node_in_group("player")
	player.openUI("music")

func _on_mouse_entered() -> void:
	get_node("../Sprite3D").modulate = Color("ffffffff")
	get_node("../Sprite3D").shaded = false
	get_node("../Sprite3D2").modulate = Color("ffffffff")
	get_node("../Sprite3D2").shaded = false

func _on_mouse_exited() -> void:
	get_node("../Sprite3D").modulate = _secondary_color
	get_node("../Sprite3D").shaded = true
	get_node("../Sprite3D2").modulate = _secondary_color
	get_node("../Sprite3D2").shaded = true
