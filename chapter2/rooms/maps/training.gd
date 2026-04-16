extends Node3D

var world = Global.get_world(Global.game_settings.word)
var checkpoint = Vector3(100.0, 0.656, 7.75)

func _ready() -> void:
	var env_scene = preload("res://chapter2/sky/skyboxBlue.tscn")
	var env_instance = env_scene.instantiate()
	add_child(env_instance)
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
		"TimeStart":
			if Global.game_settings["gui_settings"]["Language"] == "русский":
				$Player.warning("Бегите назад!!!")
			else:
				$Player.warning("Run back!!!")
			get_node("Player/head/Camera3D/timer").start_countdown(120)
			$"7/TeleportSimulation3".position.y = 0.0
			$"7/ImpenetrableField2".on(false)
			$"7/hologramText".queue_free()
			$Player.recipe([], "", "")
		"portal":
			if world["level"] <= 0:
				world["level"] = 1
			if world["stage"] <= 0:
				world["stage"] = 1
			$"8/portal".teleport("res://chapter2/rooms/GlobalMain.tscn")

func _on_kill_zona_body_entered(body: Node3D) -> void:
	print("item killZona!!!")
	print(body)
	body.global_position = Vector3(0, 0, 0)

func get_checkpoint():
	return checkpoint

func _on_spawnpoint_6_body_entered(_body: Node3D) -> void:
	checkpoint = $"6/spawnpoint".global_position

func _on_spawnpoint_8_body_entered(_body: Node3D) -> void:
	checkpoint = $"8/spawnpoint".global_position
