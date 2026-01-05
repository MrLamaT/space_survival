extends Node3D

@export var boards: bool = false
@export var need_key: bool = true 

func _ready() -> void:
	$StaticBody/Sprite3D2.visible = boards
	$StaticBody/Sprite3D3.visible = boards
	$StaticBody/Sprite3D.visible = !boards
	if !need_key:
		$StaticBody/Sprite3D2.visible = false
		remove_from_group("progressive_interactive")
	if !boards:
		remove_from_group("interactive_objects")
		remove_from_group("progressive_interactive")

func trigger_interaction():
	if need_key: 
		if Global.game_settings["Item"] != "scrap":
			return
		need_key = false
		$StaticBody/Sprite3D2.visible = false
		remove_from_group("progressive_interactive")
	else:
		teleport_player()

func teleport_player():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var direction_to_window = global_position - player.global_position
		player.AnimationPlayPlayer("BlackOut")
		await get_tree().create_timer(0.25).timeout
		if direction_to_window.z > 0:
			player.global_position = global_position + Vector3(0, 0, 2)
		else:
			player.global_position = global_position + Vector3(0, 0, -2)

func _on_mouse_entered() -> void:
	if need_key and Global.game_settings["Item"] != "scrap":
		$Label3D.visible = true
		$DoorENot.visible = true
	else:
		$DoorE.visible = true

func _on_mouse_exited() -> void:
	$DoorE.visible = false
	$Label3D.visible = false
	$DoorENot.visible = false
