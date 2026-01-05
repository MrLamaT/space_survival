extends Area3D

@onready var D1 = $D1
@onready var D1Body1 = $D1/StaticBody3D/Door1
@onready var D1Body2 = $D1/StaticBody3D/Door2
@onready var D1BodyCollision = $D1/StaticBody3D/CollisionShape3D
@onready var invisible_trigger = get_node_or_null("InvisibleTrigger")
@onready var audio_player = $AudioStreamPlayer
@onready var audio_player2 = $AudioStreamPlayer2
@export var need_key: bool = false 
@export var keyD: String = "vase" 
@export var item: NodePath
var open = false

func trigger_interaction():
	if need_key and Global.game_settings["Item"] != keyD:
		print(Global.game_settings["Item"], " ", keyD)
		return
	need_key = false
	if item and not item.is_empty():
		var item_node = get_node_or_null(item)
		if item_node:
			item_node.add_to_group("interactive_objects")
	D1BodyCollision.disabled = true
	D1.disabled = true
	audio_player.pitch_scale = randf_range(0.7, 0.9)
	audio_player.volume_db = randf_range(-23.0, -20.0)
	audio_player2.pitch_scale = randf_range(0.7, 0.9)
	audio_player2.volume_db = randf_range(-23.0, -20.0)
	if open:
		$AnimationPlayer.play("close")
		audio_player2.play()
		if invisible_trigger:
			invisible_trigger.collision_mask = 1
	else:
		$AnimationPlayer.play("open")
		audio_player.play()
		if invisible_trigger:
			invisible_trigger.collision_mask = 0
	open = !open

func _on_mouse_entered() -> void:
	if need_key and Global.game_settings["Item"] != keyD:
		$D1/Label3D.visible = true
		$D1/DoorENot.visible = true
	else:
		$D1/DoorE.visible = true
		$D1/DoorE2.visible = true

func _on_mouse_exited() -> void:
	$D1/DoorE.visible = false
	$D1/DoorE2.visible = false
	$D1/Label3D.visible = false
	$D1/DoorENot.visible = false

func _on_animation_player_animation_finished(_anim_name: String) -> void:
	print("Animation finished: ", _anim_name)
	D1BodyCollision.disabled = false
	D1.disabled = false
