extends "res://game/rooms/BaseMaps.gd"

func _ready() -> void:
	super._ready()
	$Player.weapon_system.weapon_slots[1] = world["weapon"][0]
	$Player.weapon_system.weapon_slots[2] = world["weapon"][1]
	$Player.openUI("simulation_intro")
	Global.game_settings["checkpoint"] = $Player.global_position
