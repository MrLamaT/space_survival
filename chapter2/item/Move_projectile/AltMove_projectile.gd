extends Node3D

func shoot(_dir: Vector3, _spd: float):
	pass

func _ready() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player["held_build"]:
		player.release_build(false)
	queue_free()
