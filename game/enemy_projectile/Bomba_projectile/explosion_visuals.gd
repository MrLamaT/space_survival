extends Node3D

var _flash: MeshInstance3D
var _outer_wave: MeshInstance3D
var _inner_wave: MeshInstance3D
var _rays := Node3D.new()
var _smoke := Node3D.new()
var _light := OmniLight3D.new()
var _ray_material: StandardMaterial3D
var _smoke_material: StandardMaterial3D


func _ready() -> void:
	var sphere := SphereMesh.new()
	sphere.radial_segments = 8
	sphere.rings = 3

	_flash = _make_mesh(self, sphere, _make_material(Color(2.5, 2.3, 2.0), true))
	_outer_wave = _make_mesh(self, sphere, _make_material(Color(0.8, 0.95, 1.0), true))
	_inner_wave = _make_mesh(self, sphere, _make_material(Color(1.0, 0.14, 0.06), true))

	add_child(_rays)
	_ray_material = _make_material(Color(1.6, 0.85, 0.55), true)
	var ray_mesh := CylinderMesh.new()
	ray_mesh.top_radius = 0.0
	ray_mesh.bottom_radius = 0.07
	ray_mesh.height = 1.0
	ray_mesh.radial_segments = 3

	for i in range(16):
		var direction := Vector3(
			cos(i * 2.39996),
			lerpf(-0.75, 0.85, float(i) / 15.0),
			sin(i * 2.39996)
		).normalized()
		var length := 1.4 + float(i % 5) * 0.45
		var ray := _make_mesh(_rays, ray_mesh, _ray_material)
		ray.quaternion = Quaternion(Vector3.UP, direction)
		ray.position = direction * (0.2 + length * 0.5)
		ray.scale.y = length

	add_child(_smoke)
	var gradient := Gradient.new()
	gradient.colors = PackedColorArray([
		Color(1, 1, 1, 1),
		Color(1, 1, 1, 0)
	])
	var smoke_texture := GradientTexture2D.new()
	smoke_texture.gradient = gradient
	smoke_texture.fill = GradientTexture2D.FILL_RADIAL
	smoke_texture.fill_from = Vector2(0.5, 0.5)
	smoke_texture.fill_to = Vector2(1.0, 0.5)

	_smoke_material = _make_material(Color(0.08, 0.065, 0.06), false)
	_smoke_material.albedo_texture = smoke_texture
	_smoke_material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED

	var puff_mesh := QuadMesh.new()
	for i in range(6):
		var puff := _make_mesh(_smoke, puff_mesh, _smoke_material)
		var angle := TAU * float(i) / 6.0
		puff.position = Vector3(cos(angle) * 0.25, float(i) * 0.1, sin(angle) * 0.25)
		puff.scale = Vector3.ONE * (0.75 + float(i % 3) * 0.2)

	_light.light_color = Color(1.0, 0.42, 0.12)
	_light.omni_range = 8.0
	add_child(_light)

	_animate(0.0)
	create_tween().tween_method(_animate, 0.0, 0.5, 0.5)


func _animate(t: float) -> void:
	_flash.scale = Vector3.ONE * lerpf(0.65, 2.1, _progress(t, 0.0, 0.035))
	_set_alpha(_flash.material_override, 1.0 - _progress(t, 0.0, 0.06))
	_light.light_energy = 4.0 * (1.0 - _progress(t, 0.0, 0.16))

	_rays.scale = Vector3.ONE * lerpf(0.2, 2.2, _progress(t, 0.0, 0.16))
	_set_alpha(_ray_material, 0.9 * (1.0 - _progress(t, 0.02, 0.17)))

	_outer_wave.scale = Vector3.ONE * lerpf(0.8, 7.2, _progress(t, 0.025, 0.36))
	_set_alpha(_outer_wave.material_override,
		0.5 * _progress(t, 0.02, 0.07) * (1.0 - _progress(t, 0.12, 0.36)))

	_inner_wave.scale = Vector3.ONE * lerpf(0.5, 5.3, _progress(t, 0.035, 0.39))
	_set_alpha(_inner_wave.material_override,
		0.55 * _progress(t, 0.035, 0.08) * (1.0 - _progress(t, 0.14, 0.4)))

	_smoke.scale = Vector3.ONE * lerpf(0.3, 2.5, _progress(t, 0.04, 0.5))
	_smoke.position.y = t * 1.2
	_set_alpha(_smoke_material,
		0.72 * _progress(t, 0.04, 0.12) * (1.0 - _progress(t, 0.22, 0.5)))


func _progress(t: float, start: float, end: float) -> float:
	return smoothstep(start, end, t)


func _make_material(color: Color, additive: bool) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = color
	if additive:
		material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	return material


func _make_mesh(parent: Node3D, mesh: Mesh, material: StandardMaterial3D) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = material
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(instance)
	return instance


func _set_alpha(material: StandardMaterial3D, alpha: float) -> void:
	var color := material.albedo_color
	color.a = alpha
	material.albedo_color = color
