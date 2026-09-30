extends MeshInstance3D

@export var level = -1
var world = Global.get_world(Global.game_settings.word)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		if level == -1:
			var marker = find_child("Marker3D", true, false)
			if marker and marker is Marker3D:
				body.global_position = marker.global_position
				$AudioStreamPlayer3D.global_position = marker.global_position
				var portal_scene = preload("res://game/wave/WavePortal.tscn")
				var portal_instance = portal_scene.instantiate()
				get_tree().current_scene.add_child(portal_instance)
				portal_instance.global_position = marker.global_position
				$AudioStreamPlayer3D.play()
		else:
			if world["level"] <= level:
				world["level"] = level + 1
			Global.save(Global.game_settings["word"])
			body.set_movement_enabled(false)
			SceneManager.load_scene_with_loading(Global.bonus_level.get(level))
