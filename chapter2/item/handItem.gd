extends Node3D

@export var texture: Texture2D
@export var pixel_depth := 0.025
@export var pixel_size := 0.01 

func _ready():
	if texture == null:
		push_error("Texture not assigned")
		return

	var image := texture.get_image()
	image.convert(Image.FORMAT_RGBA8)

	var mesh := ArrayMesh.new()
	var arrays := []

	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var uvs := PackedVector2Array()
	var indices := PackedInt32Array()

	var index_offset := 0
	var w := image.get_width()
	var h := image.get_height()
	
	# Вычисляем смещение для центрирования модели
	var half_width = w * pixel_size * 0.5
	var half_height = h * pixel_size * 0.5
	var half_depth = pixel_depth * 0.5

	for y in h:
		for x in w:
			var color := image.get_pixel(x, y)
			if color.a <= 0.0:
				continue

			# позиция пикселя с учетом pixel_size и смещением для центрирования
			var px: float = x * pixel_size - half_width
			var py: float = (h - y - 1) * pixel_size - half_height  # инвертируем Y для правильной ориентации
			var pz: float = -half_depth  # тоже центрируем по глубине

			index_offset = _add_voxel(
				vertices,
				normals,
				uvs,
				indices,
				index_offset,
				Vector3(px, py, pz),
				Vector3(pixel_size, pixel_size, pixel_depth),
				Vector2(float(x) / w, float(y) / h),
				Vector2(float(x + 1) / w, float(y + 1) / h)
			)

	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices

	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)

	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	var mat := StandardMaterial3D.new()
	mat.albedo_texture = texture
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED  # для отладки

	mi.material_override = mat
	add_child(mi)
	$MeshInstance3D2.queue_free()

func _add_voxel(
	vertices: PackedVector3Array,
	normals: PackedVector3Array,
	uvs: PackedVector2Array,
	indices: PackedInt32Array,
	index_offset: int,
	pos: Vector3,
	size: Vector3,
	uv_min: Vector2,
	uv_max: Vector2
) -> int:
	var x = pos.x
	var y = pos.y
	var z = pos.z
	var sx = size.x
	var sy = size.y
	var sz = size.z

	var v = [
		# front
		Vector3(x,      y,      z),
		Vector3(x + sx, y,      z),
		Vector3(x + sx, y + sy, z),
		Vector3(x,      y + sy, z),
		# back
		Vector3(x + sx, y,      z + sz),
		Vector3(x,      y,      z + sz),
		Vector3(x,      y + sy, z + sz),
		Vector3(x + sx, y + sy, z + sz),
	]

	var faces = [
		[0, 1, 2, 3],  # front
		[4, 5, 6, 7],  # back
		[5, 0, 3, 6],  # left
		[1, 4, 7, 2],  # right
		[3, 2, 7, 6],  # top
		[5, 4, 1, 0],  # bottom
	]

	var face_normals = [
		Vector3(0, 0, -1),
		Vector3(0, 0, 1),
		Vector3(-1, 0, 0),
		Vector3(1, 0, 0),
		Vector3(0, 1, 0),
		Vector3(0, -1, 0),
	]

	for i in range(6):
		var f = faces[i]
		var n = face_normals[i]

		vertices.append_array([
			v[f[0]],
			v[f[1]],
			v[f[2]],
			v[f[3]]
		])

		normals.append_array([n, n, n, n])

		# Корректные UV координаты
		uvs.append_array([
			Vector2(uv_min.x, uv_max.y),
			Vector2(uv_max.x, uv_max.y),
			Vector2(uv_max.x, uv_min.y),
			Vector2(uv_min.x, uv_min.y)
		])

		# Индексы для двух треугольников квадрата
		indices.append_array([
			index_offset, index_offset + 1, index_offset + 2,
			index_offset, index_offset + 2, index_offset + 3
		])

		index_offset += 4

	return index_offset
