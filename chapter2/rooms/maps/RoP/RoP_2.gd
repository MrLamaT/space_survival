extends Node3D

var world = Global.get_world(Global.game_settings.word)

func _ready() -> void:
	var env_scene = preload("res://chapter2/sky/skybox.tscn")
	var env_instance = env_scene.instantiate()
	add_child(env_instance)
	$NavigationRegion3D/portal/TeleportCube.teleport_contents()
	get_node("Player/head/Camera3D/timer").start_countdown()
	$Player.gravity = ProjectSettings.get_setting("physics/3d/default_gravity") / 2
	Global.game_settings["step"] = 3
	$Player._check_and_play_custom_music()

func handle_interaction(object_name: String):
	match object_name:
		"portal":
			if world["level"] <= 2:
				world["level"] = 3
			$NavigationRegion3D/Citadel/portal.teleport("res://chapter2/rooms/GlobalMain.tscn")
		"room1":
			$NavigationRegion3D/ImpenetrableField.on(true)
			if Global.game_settings["gui_settings"]["Language"] == "русский":
				$Player.warning("Непробиваемое поле открылось")
			else:
				$Player.warning("The Impenetrable Field has opened")

func _on_kill_zona_body_entered(body: Node3D) -> void:
	print("item killZona!!!")
	print(body)
	if body.is_in_group("player"):
		body.get_node("head/Camera3D/Teleport").teleport()
		await get_tree().create_timer(3).timeout
		SceneManager.load_scene_with_loading("res://chapter2/rooms/GlobalMain.tscn")
	else:
		body.global_position = Vector3(0, 0, 0)

var room5 = false

func _on_area_3d_body_entered_room5(body: Node3D) -> void:
	if body.is_in_group("player") and !room5:
		$NavigationRegion3D/ImpenetrableField2.on(false)
		room5 = true
