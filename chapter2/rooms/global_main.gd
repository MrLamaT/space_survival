extends Node3D

var painting = 0

func _ready() -> void:
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
		"portal":
			$NavigationRegion3D/portal.teleport()

func _on_grass_trig_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		body.stepGrass = true

func _on_grass_trig_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		body.stepGrass = false
