extends Node3D

var world = Global.get_world(Global.game_settings.word)

func _ready() -> void:
	var env_scene = preload("res://game/sky/skyboxBlue.tscn")
	var env_instance = env_scene.instantiate()
	add_child(env_instance)
	$Player.weapon_system.weapon_slots[1] = world["weapon"][0]
	$Player.weapon_system.weapon_slots[2] = world["weapon"][1]
	$Player.openUI("simulation_intro")
	Global.game_settings["checkpoint"] = $Player.global_position
