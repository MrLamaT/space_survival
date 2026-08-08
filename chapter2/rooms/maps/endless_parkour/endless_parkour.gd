extends Node3D

var world = Global.get_world(Global.game_settings.word)

func _ready() -> void:
	var env_scene = preload("res://chapter2/sky/skyboxBlue.tscn")
	var env_instance = env_scene.instantiate()
	add_child(env_instance)
	$Player.gravity = ProjectSettings.get_setting("physics/3d/default_gravity") / 2
	Global.game_settings["step"] = 1
	Global.game_settings["checkpoint"] = $Player.global_position
	Global.game_settings["min_y"] = -5.0

func _on_area_3d_body_entered(_body: Node3D) -> void:
	var blocks = get_tree().get_nodes_in_group("endless_parkour_block")
	for block in blocks:
		block.queue_free()
	$NavigationRegion3D/StaticBody3D.has_copied = false
