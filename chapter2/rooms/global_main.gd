extends Node3D

var world = Global.get_world(Global.game_settings.word)
var storage_scene = preload("res://chapter2/build/chest.tscn")
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
		"storage":
			var new_storage = storage_scene.instantiate()
			var storage_position = Vector3(0, 0.475, -5.0)
			var storage_rotation = Vector3(0, deg_to_rad(180), 0)
			var storage_scale = Vector3(3.0, 3.0, 3.0)
			var unique_chest_id = generate_unique_chest_id()
			new_storage.set_chest_name(unique_chest_id)
			new_storage.set_generate_items(false)
			$ship/Zona1.add_child(new_storage)
			new_storage.position = storage_position
			new_storage.rotation = storage_rotation
			new_storage.scale = storage_scale
			world.inventory[unique_chest_id] = []
			var build_data = {
				"node_path": new_storage.get_path(),
				"position": storage_position,
				"rotation": storage_rotation,
				"scale": storage_scale,
				"chest": unique_chest_id,
				"type": "storage"
			}
			world["build"].append(build_data)
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
		var target_chest = ""
		var build_type = build_item.get("type", "storage")
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
		var new_object
		if build_type == "workbench":
			new_object = workbench_scene.instantiate()
		else:
			new_object = storage_scene.instantiate()
			if build_item.has("chest"):
				target_chest = build_item["chest"]
				new_object.set_chest_name(target_chest)
				new_object.set_generate_items(false)
		$ship/Zona1.add_child(new_object)
		new_object.position = target_position
		new_object.rotation = target_rotation
		new_object.scale = target_scale
		new_object.set_meta("dynamic_build", true)
		if build_type != "workbench" and target_chest != "":
			await get_tree().process_frame
			if new_object.has_method("set_chest_name"):
				new_object.set_chest_name(target_chest)
			elif "chest" in new_object:
				new_object.chest = target_chest
	$Player.recipe([], "", "")

func generate_unique_chest_id() -> String:
	var world_data = Global.get_world(Global.game_settings.word)
	var counter = 1
	while true:
		var candidate = "chest_" + str(counter)
		if not world_data.inventory.has(candidate):
			return candidate
		counter += 1
	return ""
