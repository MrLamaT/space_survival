extends Node3D

var world = Global.get_world(Global.game_settings.word)

func _ready() -> void:
	var env_scene = preload("res://chapter2/sky/skyboxBlue.tscn")
	var env_instance = env_scene.instantiate()
	add_child(env_instance)
	Global.game_settings["step"] = 1

func handle_interaction(object_name: String):
	match object_name:
		"exit":
			var player = get_tree().get_first_node_in_group("player")
			player.get_node("head/Camera3D/Teleport").teleport()
			await get_tree().create_timer(3).timeout
			SceneManager.load_scene_with_loading("res://chapter2/rooms/GlobalMain.tscn")

func _on_kill_zona_body_entered(body: Node3D) -> void:
	print("item killZona!!!")
	print(body)
	if body.is_in_group("player"):
		body.get_node("head/Camera3D/Teleport").teleport()
		await get_tree().create_timer(3).timeout
		SceneManager.load_scene_with_loading("res://chapter2/rooms/GlobalMain.tscn")
	else:
		body.global_position = Vector3(0, 0, 0)

func get_checkpoint():
	return Vector3(0.0, 0.656, 40.0)
