extends Node3D

var world = Global.get_world(Global.game_settings.word)

func _ready() -> void:
	var env_scene = preload("res://game/sky/skyboxBlue.tscn")
	var env_instance = env_scene.instantiate()
	add_child(env_instance)
	$Player.weapon_system.weapon_slots[1] = "Summon"
	$Player.weapon_system.weapon_slots[2] = "Taser"
	$Player.weapon_system.weapon_slots[3] = "Hornet"
	$Player.weapon_system.equip_weapon($Player.weapon_system.weapon_slots.get(1, ""))
	Global.game_settings["checkpoint"] = $Player.global_position
	Global.game_settings["min_y"] = -5.0

func _on_audio_stream_player_2d_finished() -> void:
	$AudioStreamPlayer2D.play()
