extends Node3D

func shoot(_dir: Vector3, _spd: float):
	pass

func _ready() -> void:
	await get_tree().process_frame
	var wave_marker_scene = load("res://game/wave/waveMarker.tscn")
	var wave_marker = wave_marker_scene.instantiate()
	get_tree().root.add_child(wave_marker)
	wave_marker.global_position = $MeshInstance3D/Marker3D.global_position
	wave_marker.set("enemy", Global.summon["name"])
	wave_marker.set("is_boss", Global.summon["boss"])
	wave_marker.set("frozen", Global.summon["frozen"])
	wave_marker.set("aura", Global.summon["aura"])
	wave_marker.set("enemyTags", Global.summon["enemyTags"])
	wave_marker.spawn("none")
	queue_free()
