extends MeshInstance3D

func _ready() -> void:
	create_custom_material()

func create_custom_material() -> void:
	var costume_textures = {
		"Classic": "res://assets/hand/classic/c_hand1.png",
		"Home": "res://assets/hand/home/h_hand1.png",
		"Knight": "res://assets/hand/knight/k_hand1.png",
		"Phantom": "res://assets/hand/phantom/p_hand1.png",
		"Snow": "res://assets/hand/snow/s_hand1.png",
		"White": "res://assets/hand/white/w_hand1.png",
		"Zenith": "res://assets/hand/zenith/z_hand1.png",
	}
	var world = Global.get_world(Global.game_settings.word)
	var costume_key = world.get("costumes", "Classic")
	var texture_path = costume_textures.get(costume_key, "res://assets/hand/classic/c_hand1.png")
	var material = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.uv1_scale = Vector3(2.0, 2.0, -1.5)
	material.uv1_offset = Vector3(0.65, 0.5, 0.6)
	material.uv1_triplanar = true
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	var texture = load(texture_path)
	if texture:
		material.albedo_texture = texture
	self.material_override = material
