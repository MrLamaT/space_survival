extends Node3D

var world = Global.get_world(Global.game_settings.word)

func _ready() -> void:
	randomize()
	var env_scene = preload("res://chapter2/sky/skybox.tscn")
	var env_instance = env_scene.instantiate()
	add_child(env_instance)
	$ship/Zona1/portal/TeleportCube.teleport_contents()
	Global.game_settings["HP"] = 100
	Global.game_settings["step"] = 3
	Global.game_settings["IsDying"] = false
	setBuild()

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
			if world["selectWorld"] != "":
				$ship/Zona1/portal.teleport("res://chapter2/rooms/maps/RoP.tscn")
			else:
				var player = $Player
				if Global.game_settings["gui_settings"]["Language"] == "русский":
					player.warning("Выберите цель телепортации")
				else:
					player.warning("Select Teleport Target")
		"chest":
			world["build"]["chest"] += 1
			setBuild()
			if Global.game_settings["gui_settings"]["Language"] == "русский":
				$Player.warning("Строительство завершено!")
			else:
				$Player.warning("Construction complete!")

func setBuild():
	if world["build"]["chest"] >= 0:
		$ship/Zona1/chest/chest.position.y = 0.475
	if world["build"]["chest"] >= 1:
		$ship/Zona1/chest/chest2.position.y = 0.475
	if world["build"]["chest"] >= 2:
		$ship/Zona1/chest/chest3.position.y = 0.475
		$ship/Zona1/chest/InteractableObject.queue_free()
	$Player.recipe([], "", "")
	
