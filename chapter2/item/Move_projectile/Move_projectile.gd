extends Node3D

var world = Global.get_world(Global.game_settings.word)
var _already_triggered: bool = false

func shoot(_dir: Vector3, _spd: float):
	pass

func _ready() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player["held_build"]:
		player.release_build()
		queue_free()
	else:
		$Area3D/CollisionShape3D.disabled = false

func _on_area_3d_body_entered(body: Node3D) -> void:
	if _already_triggered:  
		return
	_already_triggered = true
	print(body.name)
	var player = get_tree().get_first_node_in_group("player")
	var build_node = null
	if body.get_parent() and body.get_parent().is_in_group("build") or (world["mode"] == 1 and body.get_parent().is_in_group("enemy")):
		build_node = body.get_parent()
	if world["mode"] == 1 and body.is_in_group("enemy"):
		build_node = body
	if build_node:
		if player:
			player.MoveBuild(build_node)
			queue_free() 
	else:
		queue_free() 

func _on_timer_timeout() -> void:
	queue_free() 
