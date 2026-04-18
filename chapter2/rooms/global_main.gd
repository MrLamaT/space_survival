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
			world["build"]["chest"] += 1
			if Global.game_settings["gui_settings"]["Language"] == "русский":
				$Player.warning("Строительство завершено!")
			else:
				$Player.warning("Construction complete!")
		"workbench":
			world["build"]["workbench"] += 1
			if Global.game_settings["gui_settings"]["Language"] == "русский":
				$Player.warning("Строительство завершено!")
			else:
				$Player.warning("Construction complete!")
		"light":
			world["build"]["light"] += 1
			if Global.game_settings["gui_settings"]["Language"] == "русский":
				$Player.warning("Строительство завершено!")
			else:
				$Player.warning("Construction complete!")
			for i in range(1, 10):
				get_node("ship/Zona1/wall" + str(i)).lightOn()
		"solarPanels":
			world["build"]["solar_panel"] += 1
			if Global.game_settings["gui_settings"]["Language"] == "русский":
				$Player.warning("Строительство завершено!")
			else:
				$Player.warning("Construction complete!")
		"compartment_1":
			world["build"]["compartment"] += 1
			if Global.game_settings["gui_settings"]["Language"] == "русский":
				$Player.warning("Строительство завершено!")
			else:
				$Player.warning("Construction complete!")
	setBuild()

func setBuild():
	if world["build"]["chest"] >= 0:
		$ship/Zona1/chest/chest.position.y = 0.475
	if world["build"]["chest"] >= 1:
		$ship/Zona1/chest/chest2.position.y = 0.475
	if world["build"]["chest"] >= 2:
		$ship/Zona1/chest/chest3.position.y = 0.475
		if has_node("ship/Zona1/chest/InteractableObject"):
			$ship/Zona1/chest/InteractableObject.queue_free()
	if world["build"]["workbench"] >= 1:
		$ship/Zona1/workbench/workbench.position.y = 0.45
		if has_node("ship/Zona1/workbench/InteractableObject"):
			$ship/Zona1/workbench/InteractableObject.queue_free()
	if world["build"]["light"] >= 1:
		$ship/Zona1/Light.update_torch_color(Color("f3f1c5"))
		$ship/Zona1/Light2.update_torch_color(Color("f3f1c5"))
		$ship/Zona1/Light3.update_torch_color(Color("f3f1c5"))
		if has_node("ship/Zona1/lightBuild/InteractableObject"):
			$ship/Zona1/lightBuild/InteractableObject.queue_free()
	if world["build"]["solar_panel"] >= 1:
		world["PortalTimer"] = 180
		if has_node("ship/Zona1/solarPanels/InteractableObject"):
			$ship/Zona1/solarPanels/InteractableObject.queue_free()
	if world["build"]["compartment"] >= 1:
		$ship/Zona1/wallGates.unlocking()
		if has_node("ship/Zona1/compartment/InteractableObject"):
			$ship/Zona1/compartment/InteractableObject.queue_free()
	$Player.recipe([], "", "")
