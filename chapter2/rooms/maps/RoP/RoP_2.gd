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
	Global.game_settings["step"] = 3
	Global.game_settings["min_y"] = -5.0
	$Player._check_and_play_custom_music()

func handle_interaction(object_name: String):
	match object_name:
		"room1":
			$NavigationRegion3D/ImpenetrableField.on(true)
			if Global.game_settings["gui_settings"]["Language"] == "русский":
				$Player.warning("Непробиваемое поле открылось")
			else:
				$Player.warning("The Impenetrable Field has opened")
		"room10":
			$NavigationRegion3D/ImpenetrableField5.on(true)
			$NavigationRegion3D/ImpenetrableField6.on(true)
			if Global.game_settings["gui_settings"]["Language"] == "русский":
				$Player.warning("Непробиваемое поле открылось")
			else:
				$Player.warning("The Impenetrable Field has opened")

var room5 = false
var room10 = false

func _on_area_3d_body_entered_room5(body: Node3D) -> void:
	if body.is_in_group("player") and !room5:
		$NavigationRegion3D/ImpenetrableField2.on(false)
		room5 = true

func _on_area_3d_body_entered_room10(body: Node3D) -> void:
	if body.is_in_group("player") and !room10:
		$NavigationRegion3D/ImpenetrableField6.on(false)
		$NavigationRegion3D/ImpenetrableField4.on(false)
		$NavigationRegion3D/floor_ceiling/room10/RisingRing.on()
		$NavigationRegion3D/floor_ceiling/room10/RisingRing2.on()
		$NavigationRegion3D/floor_ceiling/room10/RisingRing3.on()
		$NavigationRegion3D/floor_ceiling/room10/RisingRing4.on()
		$NavigationRegion3D/floor_ceiling/room10/RisingRing5.on()
		$NavigationRegion3D/floor_ceiling/room10/RisingRing6.on()
		room10 = true
