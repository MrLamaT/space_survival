extends Node3D

var world = Global.get_world(Global.game_settings.word)

func shoot(_dir: Vector3, _spd: float):
	pass

func _on_area_3d_body_entered(body: Node3D) -> void:
	print(body.name)
	var player = get_tree().get_first_node_in_group("player")
	var build_node = null
	if body.get_parent() and body.get_parent().is_in_group("build"):
		build_node = body.get_parent()
	if world["mode"] == 1 and body.get_parent().is_in_group("enemy"):
		body.get_parent().queue_free()
		queue_free() 
	if world["mode"] == 1 and body.is_in_group("enemy"):
		body.queue_free()
		queue_free() 
	if build_node:
		if player:
			player.DeleteBuild(build_node)
			queue_free() 
	else:
		queue_free() 

func _on_timer_timeout() -> void:
	queue_free() 
