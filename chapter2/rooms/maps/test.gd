extends Node3D

var world = Global.get_world(Global.game_settings.word)

func _ready() -> void:
	var env_scene = preload("res://chapter2/sky/skyboxBlue.tscn")
	var env_instance = env_scene.instantiate()
	add_child(env_instance)
	$NavigationRegion3D/portal/TeleportCube.teleport_contents()
	get_node("Player/head/Camera3D/timer").start_countdown(world["PortalTimer"])
	Global.game_settings["step"] = 2
	DeathBox()

func DeathBox():
	var death_point = world["PointDeath"]
	if (death_point is Vector3) and (world["inventory"]["death"] != []):
		$deathChest.global_position = death_point
	else:
		$deathChest.queue_free()
	world["PointDeath"] = ""

func handle_interaction(object_name: String):
	match object_name:
		"portal":
			$NavigationRegion3D/portal.teleport("res://chapter2/rooms/GlobalMain.tscn")

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
		body.get_node("head/Camera3D/Teleport").teleport()
		await get_tree().create_timer(3).timeout
		SceneManager.load_scene_with_loading("res://chapter2/rooms/GlobalMain.tscn")
	else:
		body.global_position = Vector3(0, 0, 0)
