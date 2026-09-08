extends "res://game/rooms/BaseMaps.gd"

func _ready() -> void:
	super._ready()
	$Player.weapon_system.weapon_slots[1] = "Vibro Spike"
	$Player.weapon_system.weapon_slots[2] = "Taser"
	$Player.weapon_system.weapon_slots[3] = "Hornet"
	$Player.weapon_system.equip_weapon($Player.weapon_system.weapon_slots.get(1, ""))
	Global.game_settings["step"] = 1
	Global.game_settings["checkpoint"] = $Player.global_position
	Global.game_settings["min_y"] = -5.0
