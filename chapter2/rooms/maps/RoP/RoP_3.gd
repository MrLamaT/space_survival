extends Node3D

var world = Global.get_world(Global.game_settings.word)

func _ready() -> void:
	var env_scene = preload("res://chapter2/sky/skybox.tscn")
	var env_instance = env_scene.instantiate()
	add_child(env_instance)
	$NavigationRegion3D/portal/TeleportCube.teleport_contents()
	$Player.gravity = ProjectSettings.get_setting("physics/3d/default_gravity") / 2
	$Player.weapon_system.weapon_slots[1] = "Vibro Spike"
	$Player.weapon_system.weapon_slots[2] = "Taser"
	$Player.weapon_system.equip_weapon($Player.weapon_system.weapon_slots.get(1, ""))
	Global.game_settings["step"] = 1
	Global.game_settings["min_y"] = -5.0
	$Player._check_and_play_custom_music()

func _on_secret_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		SceneManager.load_scene_with_loading("res://chapter2/rooms/maps/RoP/fnaf.tscn")
