extends RigidBody3D

@onready var SpriteNote = $Sprite3D
@onready var Sprite3DCitadel = $Sprite3D2
var _secondary_color: Color

func _ready() -> void:
	await get_tree().process_frame
	var music_node = get_tree().get_first_node_in_group("music")
	music_node._check_and_play_custom_music()
	_secondary_color = Color("ffffffff").darkened(0.1)
	SpriteNote.modulate = _secondary_color
	Sprite3DCitadel.modulate = _secondary_color

func trigger_interaction():
	var player = get_tree().get_first_node_in_group("player")
	player.openUI("music")

func _on_mouse_entered() -> void:
	SpriteNote.modulate = Color("ffffffff")
	SpriteNote.shaded = false
	Sprite3DCitadel.modulate = Color("ffffffff")
	Sprite3DCitadel.shaded = false

func _on_mouse_exited() -> void:
	SpriteNote.modulate = _secondary_color
	SpriteNote.shaded = true
	Sprite3DCitadel.modulate = _secondary_color
	Sprite3DCitadel.shaded = true
