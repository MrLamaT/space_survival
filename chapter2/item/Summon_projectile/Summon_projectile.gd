extends Node3D

var world = Global.get_world(Global.game_settings.word)

func shoot(_dir: Vector3, _spd: float):
	pass

func _ready() -> void:
	await get_tree().process_frame
	var nav_region = get_tree().current_scene.get_node_or_null("NavigationRegion3D")
	if not nav_region:
		return
	var wave_marker_scene = load("res://chapter2/wave/waveMarker.tscn")
	var wave_marker = wave_marker_scene.instantiate()
	nav_region.add_child(wave_marker)
	wave_marker.global_position = $MeshInstance3D/Marker3D.global_position
	wave_marker.set("enemy", Global.game_settings["summon"]["name"])
	wave_marker.set("is_boss", Global.game_settings["summon"]["boss"])
	wave_marker.set("aura", Global.game_settings["summon"]["aura"])
	wave_marker.spawn("none")
	queue_free()
