extends Area3D

@export var Gates: Node3D
var wale = true

func _ready() -> void:
	$CSGBox3D.queue_free()

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and wale:
		$AudioStreamPlayer3D.pitch_scale = randf_range(1.9, 2.1)
		$AudioStreamPlayer3D.play()
		var markers = find_children("*", "Marker3D", true, false)
		for marker in markers:
			if marker.has_method("spawn"):
				if Gates:
					marker.spawn("key")
				else:
					marker.spawn("none")
		if Gates:
			Gates.BlockSpawn(true)
			$Timer.start()
		wale = false

func _on_timer_timeout() -> void:
	var enemy_nodes = get_tree().get_nodes_in_group("enemy_wale")
	print("enemy_wale: ", enemy_nodes.size())
	if enemy_nodes.size() == 0:
		$Timer.stop()
		Gates.unlocking()
		
