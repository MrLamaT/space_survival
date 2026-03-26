extends StaticBody3D

## красный, синий, серый, жёлтый, огнеопасная, радиация
@export var skin = 1

func _ready() -> void:
	_setup_material()

func _setup_material() -> void:
	var material = StandardMaterial3D.new()
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	material.uv1_scale = Vector3(2.0, 2.0, 1.0)
	material.texture_repeat = false
	material.metallic = 1
	material.albedo_texture = preload("res://assets/textures/barrel1.png")
	if skin == 1:
		material.albedo_color = Color("752622ff")
	if skin == 2:
		material.albedo_color = Color("2b2e58ff")
	if skin == 3:
		material.albedo_color = Color("333934ff")
	if skin == 4:
		material.albedo_color = Color("756624ff")
	if skin == 5:
		material.albedo_texture = preload("res://assets/textures/barrel2.png")
	if skin == 6:
		material.albedo_texture = preload("res://assets/textures/barrel3.png")
	$MeshInstance3D.set_surface_override_material(0, material)
