extends Node3D

var world = Global.get_world(Global.game_settings.word)

func _ready() -> void:
	var env_scene = preload("res://game/sky/skybox.tscn")
	var env_instance = env_scene.instantiate()
	add_child(env_instance)
	$NavigationRegion3D/portal.teleport_contents()
	$Player.gravity = ProjectSettings.get_setting("physics/3d/default_gravity") / 2
	$Player.weapon_system.weapon_slots[1] = "Vibro Spike"
	$Player.weapon_system.weapon_slots[2] = world["weapon"][1]
	$Player.weapon_system.equip_weapon($Player.weapon_system.weapon_slots.get(1, ""))
	Global.game_settings["min_y"] = -5.0
