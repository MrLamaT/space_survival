extends Node3D

var painting = 0

func _ready() -> void:
	$Player.startSpreedrun()
	$Player.PlayerDeath(-1)
	$NavigationRegion3D/Living/Label3D.text = Global.game_settings["password"].substr(0, 2) + "??"
	$NavigationRegion3D3/attic/Label3D.text = "??" + Global.game_settings["password"].substr(2, 5)
	setup_seasonal_materials()
	var env_scene = preload("res://chapter2/sky/skybox.tscn")
	var env_instance = env_scene.instantiate()
	add_child(env_instance)

func setup_seasonal_materials():
	var material = StandardMaterial3D.new()
	if !Global.game_settings["ModSeason"]:
		material.albedo_color = Color("c2c4d0")
	else:
		material.albedo_color = Color("323f18")
		$NavigationRegion3D/outdoors/GPUParticles3D.queue_free()
		$NavigationRegion3D/outdoors/GPUParticles3D2.queue_free()
		$NavigationRegion3D/outdoors/GPUParticles3D3.queue_free()
		$NavigationRegion3D/outdoors2/GPUParticles3D4.queue_free()
	material.roughness = 0.8  
	material.metallic = 0.0   
	if $NavigationRegion3D/floor_ceiling/dirt/CSGCombiner3D/CSGBox3D:
		$NavigationRegion3D/floor_ceiling/dirt/CSGCombiner3D/CSGBox3D.material = material
	else:
		push_error("CSGBox3D не найден!")
	if $NavigationRegion3D/floor_ceiling/dirt2/CSGCombiner3D/CSGBox3D:
		$NavigationRegion3D/floor_ceiling/dirt2/CSGCombiner3D/CSGBox3D.material = material
	else:
		push_error("CSGBox3D не найден!")

func _on_kill_zona_body_entered(body: Node3D) -> void:
	print("item killZona!!!")
	print(body)
	if body.is_in_group("player"):
		if Global.game_settings["affected_by_gravity"]:
			body.global_position = Vector3(0, 1, 0)
	else:
		body.global_position = Vector3(0, 1, 0)

func handle_interaction(object_name: String):
	match object_name:
		"painting":
			$NavigationRegion3D/PlayerRoom/board.queue_free()
			$NavigationRegion3D/PlayerRoom/InteractableObject.queue_free()
			$Player.interaction_manager.pick_up_item($NavigationRegion3D/PlayerRoom/Item1)
		"painting2":
			$NavigationRegion3D/Living/board5.queue_free()
			$NavigationRegion3D/Living/InteractableObject.queue_free()
			$Player.interaction_manager.pick_up_item($NavigationRegion3D/Living/Item)
		"GIVEpainting":
			if Global.game_settings["Item"] == "painting2":
				$Player.clear_item()
				$NavigationRegion3D/cabinet/board2.visible = true
				$NavigationRegion3D/cabinet/InteractableObject2.queue_free()
				painting += 1
				if painting > 1:
					$NavigationRegion3D/cabinet/Opendoors2.trigger_interaction()
		"GIVEpainting2":
			if Global.game_settings["Item"] == "painting":
				$Player.clear_item()
				$NavigationRegion3D/cabinet/board3.visible = true
				$NavigationRegion3D/cabinet/InteractableObject.queue_free()
				painting += 1
				if painting > 1:
					$NavigationRegion3D/cabinet/Opendoors2.trigger_interaction()
		"SpiderDoor":
			if Global.game_settings["Item"] == "battery":
				$Player.clear_item()
				$NavigationRegion3D2/basement/SpiderDoor/Sprite3D.visible = true
				$NavigationRegion3D2/basement/SpiderDoor/InteractableObject2.queue_free()
				$NavigationRegion3D2/basement/SpiderDoor/StaticBody3D/CollisionShape3D.queue_free()
				$NavigationRegion3D2/basement/SpiderDoor/AnimationPlayer.play("spider")
		"book":
			if Global.game_settings["Item"] == "book":
				$Player.clear_item()
				$NavigationRegion3D/barn/BookTable/Sprite3D.visible = true
				$NavigationRegion3D/barn/InteractableObject.queue_free()
				$NavigationRegion3D/barn/StaticBody3D/CollisionShape3D.queue_free()
				$NavigationRegion3D/barn/AnimationPlayer.play("book")
		"EXIT":
			if Global.game_settings["doorExit"] >= 3:
				$NavigationRegion3D/outdoors/StreetWall/InteractableObject.position = Vector3(1.187, 2.793, 2.37)
				$NavigationRegion3D/outdoors/StreetWall/InteractableObject.queue_free()
				$NavigationRegion3D/outdoors/cutscene/Camera3D.current = true
				$Player.global_position = Vector3(2.599, 0.656, 2.599)
				Global.game_settings["god"] = true
				$NavigationRegion3D/outdoors/cutscene/AnimationPlayer.play("TheEnd")
				await get_tree().create_timer(4.0).timeout
				$Player/head/Camera3D/TheEND.visible = true
				$Player/head/Camera3D/TheEND2.visible = true
				$Player.stopSpreedrun()
				$Player.SpreedrunMod(true)
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _on_grass_trig_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		body.stepGrass = true

func _on_grass_trig_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		body.stepGrass = false
