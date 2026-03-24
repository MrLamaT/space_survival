extends Node3D

var world = Global.get_world(Global.game_settings.word)
var checkpoint = Vector3(100.0, 0.656, 7.75)

func _ready() -> void:
	Global.game_settings["step"] = 1
	$Player.openUI("simulation_intro")
	$"4/PC1".notificationOn(true)

func handle_interaction(object_name: String):
	match object_name:
		"exit":
			var player = get_tree().get_first_node_in_group("player")
			player.get_node("head/Camera3D/Teleport").teleport()
			await get_tree().create_timer(3).timeout
			SceneManager.load_scene_with_loading("res://chapter2/rooms/GlobalMain.tscn")
		"workbench":
			if Global.game_settings["gui_settings"]["Language"] == "русский":
				$Player.warning("Строительство завершено!")
			else:
				$Player.warning("Construction complete!")
			$"4/workbench/workbench".position.y = 0.45
			$"4/workbench/InteractableObject".queue_free()
			$Player.recipe([], "", "")

func _on_kill_zona_body_entered(body: Node3D) -> void:
	print("item killZona!!!")
	print(body)
	body.global_position = Vector3(0, 0, 0)

func get_checkpoint():
	return checkpoint
