extends Area3D

var closed = true
@onready var audio_player = $AudioStreamPlayer
@export var need_key: bool = true 

func trigger_interaction():
	if Global.game_settings["Item"] != "screwdriver":
		return
	need_key = false
	$StaticBody3D/CollisionShape3D.set_deferred("disabled", true)
	audio_player.pitch_scale = randf_range(0.9, 1.1)
	audio_player.volume_db = randf_range(-3.0, 0.0)
	audio_player.play()
	$MeshInstance3D.visible = false
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
