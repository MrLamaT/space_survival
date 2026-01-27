extends Node3D

var painting = 0

func _ready() -> void:
	var env_scene = preload("res://chapter2/sky/skybox.tscn")
	var env_instance = env_scene.instantiate()
	add_child(env_instance)
	$ship/Zona1/portal/TeleportCube.teleport_contents()

func _on_kill_zona_body_entered(body: Node3D) -> void:
	print("item killZona!!!")
	print(body)
	if body.is_in_group("player"):
		body.get_node("head/Camera3D/Teleport").teleport()
		await get_tree().create_timer(3).timeout
		body.global_position = Vector3(0, 0.656, 12.0)
	else:
		body.global_position = Vector3(0, 0.656, 12.0)

func handle_interaction(object_name: String):
	match object_name:
		"portal":
			$ship/Zona1/portal.teleport("res://chapter2/rooms/maps/test.tscn")
