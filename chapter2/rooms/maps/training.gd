extends Node3D

var world = Global.get_world(Global.game_settings.word)

func _ready() -> void:
	Global.game_settings["step"] = 1
	get_tree().get_first_node_in_group("player").openUI("simulation_intro")

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
	body.global_position = Vector3(0, 0, 0)
