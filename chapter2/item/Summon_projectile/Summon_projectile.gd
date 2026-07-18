extends Node3D

var world = Global.get_world(Global.game_settings.word)

func shoot(_dir: Vector3, _spd: float):
	pass

func _ready() -> void:
	await get_tree().process_frame
	if Global.game_settings["summon"]["name"] == "block":
		call_deferred("_build_block")
		return
	var nav_region = get_tree().current_scene.get_node_or_null("NavigationRegion3D")
	if not nav_region:
		return
	var wave_marker_scene = load("res://chapter2/wave/waveMarker.tscn")
	var wave_marker = wave_marker_scene.instantiate()
	nav_region.add_child(wave_marker)
	wave_marker.global_position = $MeshInstance3D/Marker3D.global_position
	wave_marker.set("enemy", Global.game_settings["summon"]["name"])
	wave_marker.set("is_boss", Global.game_settings["summon"]["boss"])
	wave_marker.set("aura", Global.game_settings["summon"]["aura"])
	wave_marker.set("enemyTags", Global.game_settings["summon"]["enemyTags"])
	wave_marker.spawn("none")
	queue_free()

func _build_block() -> void:
	var player = get_tree().get_first_node_in_group("player")
	var camera = player.get_node_or_null("head/Camera3D")
	var grid_size = 1.0  # Размер ячейки сетки (1.0 = стандартный блок)
	var grid_offset = Vector3(0.0, -0.5, 0.0)  # Сдвиг всей сетки (можно менять)
	var ray_length = 5.0
	var space_state: PhysicsDirectSpaceState3D
	if camera.is_inside_tree():
		space_state = camera.get_world_3d().direct_space_state
	else:
		space_state = get_tree().current_scene.get_world_3d().direct_space_state
	if not space_state:
		print("Не удалось получить пространство физики")
		queue_free()
		return
	var from = camera.global_position
	var to = from - camera.global_transform.basis.z * ray_length
	var query = PhysicsRayQueryParameters3D.new()
	query.from = from
	query.to = to
	query.collision_mask = 0xFFFFFFFF  
	query.exclude = [self]
	var result = space_state.intersect_ray(query)
	if not result:
		print("Луч никуда не попал, блок не поставлен")
		queue_free()
		return
	var place_position = result.position + result.normal * 0.5
	place_position = Vector3(
		floor((place_position.x - grid_offset.x) / grid_size) * grid_size + grid_offset.x + grid_size/2,
		floor((place_position.y - grid_offset.y) / grid_size) * grid_size + grid_offset.y + grid_size/2,
		floor((place_position.z - grid_offset.z) / grid_size) * grid_size + grid_offset.z + grid_size/2
	)
	var check_query = PhysicsShapeQueryParameters3D.new()
	var box_check = BoxShape3D.new()
	box_check.size = Vector3(grid_size * 0.9, grid_size * 0.9, grid_size * 0.9)  
	check_query.shape = box_check
	check_query.transform.origin = place_position
	var collisions = space_state.intersect_shape(check_query)
	for col in collisions:
		var col_node = col.collider
		if col_node is StaticBody3D and (col_node.collision_layer & 4 != 0):  
			print("Место занято другим блоком, нельзя поставить")
			queue_free()
			return
	var static_body = StaticBody3D.new()
	static_body.collision_layer = 4  
	static_body.collision_mask = 0
	var mesh_instance = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(1, 1, 1)
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.6, 0.4, 0.2)
	box_mesh.material = material
	mesh_instance.mesh = box_mesh
	var collision_shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(1, 1, 1)
	collision_shape.shape = box_shape
	static_body.add_child(mesh_instance)
	static_body.add_child(collision_shape)
	get_tree().current_scene.add_child(static_body)
	static_body.global_position = place_position
	print("Блок поставлен на позиции: ", place_position)
	queue_free()
