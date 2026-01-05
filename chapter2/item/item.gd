extends RigidBody3D

@export var available: bool = true
@export var item_texture: Texture2D
@export var item_texture_1: Texture2D
@export var item_texture_2: Texture2D
@export var item_texture_3: Texture2D
@export var item_texture_4: Texture2D
@export var item_texture_5: Texture2D

@onready var audio_player = $AudioStreamPlayer3D
var check = false

func _ready():
	if !Global.game_settings["debugging"]:
		$test.queue_free()
	else:
		$test.visible = true
	apply_preset_texture()
	
	if !available:
		remove_from_group("interactive_objects")
	
	$MeshInstance3D.queue_free()
	create_item_mesh()

func apply_preset_texture():
	var current_preset = Global.game_settings["preset"]
	var preset_texture = null
	
	match current_preset:
		1:
			preset_texture = item_texture_1
		2:
			preset_texture = item_texture_2
		3:
			preset_texture = item_texture_3
		4:
			preset_texture = item_texture_4
		5:
			preset_texture = item_texture_5
		_:
			preset_texture = item_texture 
	
	if preset_texture:
		item_texture = preset_texture
	else:
		if not item_texture:
			queue_free()

func create_item_mesh():
	# Основной меш
	var mesh_instance = MeshInstance3D.new()
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(1, 1)
	var material = StandardMaterial3D.new()
	material.albedo_texture = item_texture
	material.flags_transparent = true
	material.params_cull_mode = StandardMaterial3D.CULL_DISABLED
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	mesh_instance.mesh = plane_mesh
	mesh_instance.material_override = material
	add_child(mesh_instance)

func _on_body_entered(body):
	if body is StaticBody3D or body is RigidBody3D or body is CharacterBody3D:
		if !check:
			play_collision_sound()
			check = true

func play_collision_sound():
	var targets = get_tree().get_nodes_in_group("enemy_targets1")
	if targets.size() > 0:
		var current_target = targets[0]
		current_target.global_position = global_position
		current_target.timeStart()
	audio_player.pitch_scale = randf_range(0.9, 1.1)
	audio_player.play()

func _on_mouse_entered() -> void:
	pass # Replace with function body.

func _on_mouse_exited() -> void:
	pass # Replace with function body.
