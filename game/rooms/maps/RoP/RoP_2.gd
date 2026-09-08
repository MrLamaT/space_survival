extends "res://game/rooms/BaseMaps.gd"

func _ready() -> void:
	super._ready()
	$NavigationRegion3D/portal.teleport_contents()
	$Player.gravity = ProjectSettings.get_setting("physics/3d/default_gravity") / 2
	$Player.weapon_system.weapon_slots[1] = "Vibro Spike"
	$Player.weapon_system.weapon_slots[2] = "Taser"
	$Player.weapon_system.weapon_slots[3] = world["weapon"][2]
	$Player.weapon_system.equip_weapon($Player.weapon_system.weapon_slots.get(1, ""))
	Global.game_settings["min_y"] = -5.0

func handle_interaction(object_name: String):
	match object_name:
		"room1":
			$NavigationRegion3D/floor_ceiling/room1/wallGates3.unlocking()
			$NavigationRegion3D/floor_ceiling/room3/wallGates.unlocking()
			if Global.game_settings["gui_settings"]["Language"] == "русский":
				$Player.warning("Проход открыт")
			else:
				$Player.warning("A door opens")
		"room10":
			$NavigationRegion3D/ImpenetrableField5.on(true)
			if Global.game_settings["gui_settings"]["Language"] == "русский":
				$Player.warning("Непробиваемое поле открылось")
			else:
				$Player.warning("The Impenetrable Field has opened")

func activate_trigger(object_name: String):
	match object_name:
		"boss":
			$NavigationRegion3D/floor_ceiling/room10/RisingRing.on()
			$NavigationRegion3D/floor_ceiling/room10/RisingRing2.on()
			$NavigationRegion3D/floor_ceiling/room10/RisingRing3.on()
			$NavigationRegion3D/floor_ceiling/room10/RisingRing4.on()
			$NavigationRegion3D/floor_ceiling/room10/RisingRing5.on()
			$NavigationRegion3D/floor_ceiling/room10/RisingRing6.on()
