extends Node3D

var world = Global.get_world(Global.game_settings.word)
var _already_triggered: bool = false
var delete_portal_scene = preload("res://chapter2/wave/DeletePortal.tscn")

func shoot(_dir: Vector3, _spd: float):
	pass

func spawn_delete_portal(Pposition: Vector3):
	var portal = delete_portal_scene.instantiate()
	get_tree().root.add_child(portal)
	portal.global_position = Pposition

func _on_area_3d_body_entered(_body: Node3D) -> void:
	if _already_triggered: 
		return
	var overlapping_bodies = $Area3D.get_overlapping_bodies()
	var target_body = null
	for potential_body in overlapping_bodies:
		if potential_body.is_in_group("enemy") or potential_body.is_in_group("prop"):
			target_body = potential_body
			break
	if target_body:
		_already_triggered = true
		var delete_position = target_body.global_position
		spawn_delete_portal(delete_position)
		target_body.queue_free()
		queue_free()
	else:
		pass

func _on_timer_timeout() -> void:
	queue_free() 
