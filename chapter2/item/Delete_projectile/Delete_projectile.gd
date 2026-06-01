extends Node3D

var world = Global.get_world(Global.game_settings.word)
var delete_portal_scene = preload("res://chapter2/wave/DeletePortal.tscn")

func shoot(_dir: Vector3, _spd: float):
	pass

func spawn_delete_portal(Pposition: Vector3):
	var portal = delete_portal_scene.instantiate()
	get_tree().root.add_child(portal)
	portal.global_position = Pposition

func _on_area_3d_body_entered(body: Node3D) -> void:
	print(body.name)
	var player = get_tree().get_first_node_in_group("player")
	var build_node = null
	var delete_position = body.global_position
	if body.get_parent() and body.get_parent().is_in_group("build"):
		build_node = body.get_parent()
		delete_position = build_node.global_position
	if world["mode"] == 1 and body.get_parent().is_in_group("enemy"):
		spawn_delete_portal(delete_position)
		body.get_parent().queue_free()
		queue_free() 
	if world["mode"] == 1 and body.is_in_group("enemy"):
		spawn_delete_portal(delete_position)
		body.queue_free()
		queue_free() 
	if build_node:
		if player:
			player.DeleteBuild(build_node)
			spawn_delete_portal(delete_position)
			queue_free() 
	else:
		queue_free() 

func _on_timer_timeout() -> void:
	queue_free() 
