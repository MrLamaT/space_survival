extends Node3D

var world = Global.get_world(Global.game_settings.word)
var workbench_scene = preload("res://chapter2/build/workbench.tscn")

func _ready() -> void:
	randomize()
	var env_scene = preload("res://chapter2/sky/skybox.tscn")
	var env_instance = env_scene.instantiate()
	add_child(env_instance)
	$ship/Zona1/portal/TeleportCube.teleport_contents()
	Global.game_settings["step"] = 3
	Global.game_settings["IsDying"] = false
	setBuild()

func handle_interaction(object_name: String):
	match object_name:
		"workbench":
			var new_workbench = workbench_scene.instantiate()
			var workbench_position = Vector3(0, 0.45, -5.0)
			var workbench_rotation = Vector3(0, deg_to_rad(180), 0)
			var workbench_scale = Vector3(1.25, 1.25, 1.25)
			$ship/Zona1.add_child(new_workbench)
			new_workbench.position = workbench_position
			new_workbench.rotation = workbench_rotation
			new_workbench.scale = workbench_scale
			var build_data = {
				"node_path": new_workbench.get_path(),
				"position": workbench_position,
				"rotation": workbench_rotation,
				"scale": workbench_scale,
				"type": "workbench"
			}
			world["build"].append(build_data)
	if Global.game_settings["gui_settings"]["Language"] == "русский":
		$Player.warning("Строительство завершено!")
	else:
		$Player.warning("Construction complete!")
	$Player.position = Vector3(0.0, 0.656, 12.0)

func setBuild():
	for child in $ship/Zona1.get_children():
		if child.has_meta("dynamic_build"):
			child.queue_free()
	for build_item in world["build"]:
		var target_position = Vector3()
		var target_rotation = Vector3()
		var target_scale = Vector3()
		var build_type = build_item.get("type", "workbench")
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
		if typeof(build_item["scale"]) == TYPE_STRING:
			var scale_str = build_item["scale"].replace("(", "").replace(")", "").split(",")
			if scale_str.size() == 3:
				target_scale = Vector3(float(scale_str[0]), float(scale_str[1]), float(scale_str[2]))
		else:
			target_scale = build_item["scale"]
		var new_object = create_building(build_type)
		if new_object == null:
			continue
		$ship/Zona1.add_child(new_object)
		await get_tree().process_frame
		build_item["node_path"] = new_object.get_path()
		new_object.position = target_position
		new_object.rotation = target_rotation
		new_object.scale = target_scale
		new_object.set_meta("dynamic_build", true)
	$Player.recipe([], "", "")

func create_building(build_type: String):
	match build_type:
		"workbench":
			return workbench_scene.instantiate()
		_:
			print("Неизвестный тип постройки: ", build_type)
			return null
