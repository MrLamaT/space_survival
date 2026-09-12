extends Area3D

@export var img: Texture
@export var global_key = ""
@export var id = 1

var _secondary_color: Color

func _ready() -> void:
	_secondary_color = Color("616380").darkened(0.1)
	$CanvasLayer/Sprite2D2.texture = img
	var world_data = Global.get_world(Global.game_settings.word)
	var key = str(global_key) + "_" + str(id)
	if world_data.inventory.has(key):
		$Sprite3D.modulate = _secondary_color
		$Sprite3D.shaded = true
		$AnimationPlayer.play("open")
		remove_from_group("interactive_objects")

func trigger_interaction():
	var world_data = Global.get_world(Global.game_settings.word)
	world_data.inventory.append(str(global_key) + "_" + str(id))
	$CanvasLayer/AnimationPlayer.play("obtaining")
	$Sprite3D.modulate = _secondary_color
	$Sprite3D.shaded = true
	$AnimationPlayer.play("open")
	remove_from_group("interactive_objects")

func _on_mouse_entered() -> void:
	pass

func _on_mouse_exited() -> void:
	pass
