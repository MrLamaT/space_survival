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
		await get_tree().process_frame

func _on_area_3d_body_entered(_body: Node3D) -> void:
	if _already_triggered:  
		return
	var overlapping_bodies = $Area3D.get_overlapping_bodies()
	var target_build = null
	for potential_body in overlapping_bodies:
		if potential_body.is_in_group("build") or potential_body.is_in_group("enemy") or potential_body.is_in_group("prop"):
			target_build = potential_body
			break
	if target_build:
		_already_triggered = true
		var player = get_tree().get_first_node_in_group("player")
		if player:
			player.MoveBuild(target_build)
			queue_free()
	else:
		pass

func _on_timer_timeout() -> void:
	queue_free() 
