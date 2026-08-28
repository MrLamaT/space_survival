extends Node3D

var world = Global.get_world(Global.game_settings.word)

const COLORS = {
	"white": Color("cfd5d6"),
	"orange": Color("e06101"),
	"purple": Color("a9309f"), 
	"aqua": Color("2489c7"),
	"yellow": Color("f1af15"), 
	"lime": Color("5ea919"),  
	"pink": Color("d6658f"),   
	"grey": Color("373a3e"), 
	"light gray": Color("7d7d73"),
	"turquoise": Color("157788"),
	"violet": Color("64209c"),
	"blue": Color("2d2f8f"),   
	"brown": Color("603c20"), 
	"green": Color("495b24"),   
	"red": Color("8e2121"),     
	"black": Color("080a0f")     
}

const BLOCK_SCENES = {
	"plank": "res://game/blocks/plank.tscn",
	"grass": "res://game/blocks/grass.tscn",
	"grid": "res://game/blocks/grid.tscn",
	"sand": "res://game/blocks/sand.tscn",
	"stone": "res://game/blocks/RoPstone.tscn",
	"simulation blue": "res://game/blocks/simulation_blue.tscn",
	"simulation purple": "res://game/blocks/simulation_purple.tscn",
	"backrooms": "res://game/blocks/backroomsWall.tscn",
	"metal": "res://game/blocks/metal.tscn",
	"glass": "res://game/blocks/glass.tscn",
	"sercilist": "res://game/blocks/sercilist.tscn",
	"ice": "res://game/blocks/ice.tscn",
}

const BLOCK_SIZE = 1.2  # Размер блока

func shoot(_dir: Vector3, _spd: float):
	pass

func _ready() -> void:
	await get_tree().process_frame
	call_deferred("_build_block")

func _build_block() -> void:
	var player = get_tree().get_first_node_in_group("player")
	var camera = player.get_node_or_null("head/Camera3D")
	var grid_offset = Vector3(0.0, -0.5, 0.0)
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
	
	var place_position = result.position + result.normal * (BLOCK_SIZE / 2)
	place_position = Vector3(
		floor((place_position.x - grid_offset.x) / BLOCK_SIZE) * BLOCK_SIZE + grid_offset.x + BLOCK_SIZE/2,
		floor((place_position.y - grid_offset.y) / BLOCK_SIZE) * BLOCK_SIZE + grid_offset.y + BLOCK_SIZE/2,
		floor((place_position.z - grid_offset.z) / BLOCK_SIZE) * BLOCK_SIZE + grid_offset.z + BLOCK_SIZE/2
	)
	
	var check_query = PhysicsShapeQueryParameters3D.new()
	var box_check = BoxShape3D.new()
	box_check.size = Vector3(BLOCK_SIZE * 0.9, BLOCK_SIZE * 0.9, BLOCK_SIZE * 0.9)  
	check_query.shape = box_check
	check_query.transform.origin = place_position
	var collisions = space_state.intersect_shape(check_query)
	
	for col in collisions:
		var col_node = col.collider
		if col_node is StaticBody3D and (col_node.collision_layer & 4 != 0):  
			print("Место занято другим блоком, нельзя поставить")
			queue_free()
			return
	
	var block_name = Global.game_settings.get("summon_block", {}).get("name", "")
	
	if block_name.to_lower() in COLORS:
		_create_colored_block(place_position, block_name.to_lower())
	else:
		_create_scene_block(place_position, block_name.to_lower())
	
	queue_free()

func _create_colored_block(block_position: Vector3, color_name: String) -> void:
	var static_body = StaticBody3D.new()
	static_body.collision_layer = 4  
	static_body.collision_mask = 0
	static_body.add_to_group("block")
	
	var mesh_instance = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(BLOCK_SIZE, BLOCK_SIZE, BLOCK_SIZE)
	
	var material = StandardMaterial3D.new()
	material.albedo_color = COLORS[color_name]
	box_mesh.material = material
	
	mesh_instance.mesh = box_mesh
	
	var collision_shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(BLOCK_SIZE, BLOCK_SIZE, BLOCK_SIZE)
	collision_shape.shape = box_shape
	
	static_body.add_child(mesh_instance)
	static_body.add_child(collision_shape)
	
	get_tree().current_scene.add_child(static_body)
	static_body.global_position = block_position
	print("Цветной блок ", color_name, " поставлен на позиции: ", block_position)

func _create_scene_block(block_position: Vector3, block_name: String) -> void:
	var scene_path = BLOCK_SCENES.get(block_name)
	if not scene_path:
		print("Неизвестный блок: ", block_name)
		return
	
	var block_scene = load(scene_path)
	if not block_scene:
		print("Не удалось загрузить сцену: ", scene_path)
		return
	
	var block_instance = block_scene.instantiate()
	block_instance.add_to_group("block")
	get_tree().current_scene.add_child(block_instance)
	block_instance.global_position = block_position
	
	var scale_factor = BLOCK_SIZE / 1.0 
	block_instance.scale = Vector3(scale_factor, scale_factor, scale_factor)
	
	print("Сцена блока ", block_name, " поставлена на позиции: ", block_position)
