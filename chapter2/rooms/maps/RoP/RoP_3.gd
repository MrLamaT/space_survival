extends Node3D

var world = Global.get_world(Global.game_settings.word)

func _ready() -> void:
	var env_scene = preload("res://chapter2/sky/skybox.tscn")
	var env_instance = env_scene.instantiate()
	add_child(env_instance)
	$NavigationRegion3D/portal/TeleportCube.teleport_contents()
	$Player.gravity = ProjectSettings.get_setting("physics/3d/default_gravity") / 2
	Global.game_settings["step"] = 1
	$Player._check_and_play_custom_music()

func handle_interaction(object_name: String):
	match object_name:
		"portal":
			if world["level"] <= 3:
				world["level"] = 4
			$NavigationRegion3D/Citadel/portal.teleport("res://chapter2/rooms/GlobalMain.tscn")
