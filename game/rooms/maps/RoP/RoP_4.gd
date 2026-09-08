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
