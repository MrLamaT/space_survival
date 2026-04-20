extends Node3D

var world = Global.get_world(Global.game_settings.word)

func _ready() -> void:
	randomize()
	var env_scene = preload("res://chapter2/sky/skybox.tscn")
	var env_instance = env_scene.instantiate()
	add_child(env_instance)
	$ship/Zona1/portal/TeleportCube.teleport_contents()
	Global.game_settings["step"] = 3
	Global.game_settings["IsDying"] = false
	setBuild()
	$ship/Zona1/PC2.notificationOn(true)

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
		"chest":
			var build_data = {
				"node_path": "ship/Zona1/chest/chest" + str(world["build"].size() + 1),
				"position": Vector3(0, 0.475, -5.0),
				"rotation": Vector3(0, deg_to_rad(180), 0)
			}
			world["build"].append(build_data)
		"workbench":
			var build_data = {
				"node_path": "ship/Zona1/workbench/workbench",
				"position": Vector3(0, 0.45, -5.0),
				"rotation": Vector3(0, deg_to_rad(180), 0)
			}
			world["build"].append(build_data)
	if Global.game_settings["gui_settings"]["Language"] == "русский":
		$Player.warning("Строительство завершено!")
	else:
		$Player.warning("Construction complete!")
	setBuild()
	$Player.position = Vector3(0.0, 0.656, 12.0)

func setBuild():
	for build_item in world["build"]:
		var node_path = build_item["node_path"]
		var target_position = Vector3()
		var target_rotation = Vector3()
		if typeof(build_item["position"]) == TYPE_STRING:
			var pos_str = build_item["position"].replace("(", "").replace(")", "").split(",")
			if pos_str.size() == 3:
				target_position = Vector3(float(pos_str[0]), float(pos_str[1]), float(pos_str[2]))
		else:
			target_position = build_item["position"]
		if typeof(build_item["rotation"]) == TYPE_STRING:
			var rot_str = build_item["rotation"].replace("(", "").replace(")", "").split(",")
			if rot_str.size() == 3:
				target_rotation = Vector3(float(rot_str[0]), float(rot_str[1]), float(rot_str[2]))
		else:
			target_rotation = build_item["rotation"]
		if has_node(node_path):
			var node = get_node(node_path)
			node.position = target_position
			node.rotation = target_rotation
			if node.has_node("InteractableObject"):
				node.get_node("InteractableObject").queue_free()
	$Player.recipe([], "", "")
