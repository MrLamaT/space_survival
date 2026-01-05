extends Area3D

@onready var invisible_trigger = get_node_or_null("InvisibleTrigger")
@onready var audio_player = $AudioStreamPlayer
@export var need_key: bool = true 
@export var item: NodePath
var closed = true

func trigger_interaction():
	if Global.game_settings["Item"] != "screwdriver":
		return
	need_key = false
	if item and not item.is_empty():
		var item_node = get_node_or_null(item)
		if item_node:
			item_node.add_to_group("interactive_objects")
	audio_player.pitch_scale = randf_range(0.9, 1.1)
	audio_player.volume_db = randf_range(-3.0, 0.0)
	audio_player.play()
	$MeshInstance3D.queue_free()
	$StaticBody3D2.queue_free()
	$CollisionShape3D2.queue_free()
	remove_from_group("interactive_objects")

func _on_mouse_entered() -> void:
	if need_key and Global.game_settings["Item"] != "screwdriver":
		$Label3D.visible = true
		$DoorENot.visible = true
	else:
		$DoorE.visible = true

func _on_mouse_exited() -> void:
	$DoorE.visible = false
	$Label3D.visible = false
	$DoorENot.visible = false
