@tool
extends MeshInstance3D
class_name PixelAtlasBox

# ============================================================
# РАЗМЕР КУБА И ПРАВИЛО КООРДИНАТ
# ============================================================
# «От» — первый пиксель включительно; «До» — граница после последнего.
# Пример: от (16, 0) до (32, 16) выбирает квадрат 16×16.
@export var box_size := Vector3.ONE:
	set(value):
		box_size = Vector3(maxf(absf(value.x), 0.001), maxf(absf(value.y), 0.001), maxf(absf(value.z), 0.001))
		_request_rebuild()

# ============================================================
# ПЕРЕДНЯЯ ГРАНЬ (+Z)
# ============================================================
@export_group("Передняя грань (+Z)")
@export var front_texture: Texture2D = preload("res://assets/textures/standard.png"):
	set(value):
		front_texture = value
		_request_rebuild()
@export var front_from := Vector2i(0, 0):
	set(value):
		front_from = value
		_request_rebuild()
@export var front_to := Vector2i(16, 16):
	set(value):
		front_to = value
		_request_rebuild()

# ============================================================
# ЗАДНЯЯ ГРАНЬ (-Z)
# ============================================================
@export_group("Задняя грань (-Z)")
@export var back_texture: Texture2D = preload("res://assets/textures/standard.png"):
	set(value):
		back_texture = value
		_request_rebuild()
@export var back_from := Vector2i(16, 0):
	set(value):
		back_from = value
		_request_rebuild()
@export var back_to := Vector2i(32, 16):
	set(value):
		back_to = value
		_request_rebuild()

# ============================================================
# ПРАВАЯ ГРАНЬ (+X)
# ============================================================
@export_group("Правая грань (+X)")
@export var right_texture: Texture2D = preload("res://assets/textures/standard.png"):
	set(value):
		right_texture = value
		_request_rebuild()
@export var right_from := Vector2i(32, 0):
	set(value):
		right_from = value
		_request_rebuild()
@export var right_to := Vector2i(48, 16):
	set(value):
		right_to = value
		_request_rebuild()

# ============================================================
# ЛЕВАЯ ГРАНЬ (-X)
# ============================================================
@export_group("Левая грань (-X)")
@export var left_texture: Texture2D = preload("res://assets/textures/standard.png"):
	set(value):
		left_texture = value
		_request_rebuild()
@export var left_from := Vector2i(0, 16):
	set(value):
		left_from = value
		_request_rebuild()
@export var left_to := Vector2i(16, 32):
	set(value):
		left_to = value
		_request_rebuild()

# ============================================================
# ВЕРХНЯЯ ГРАНЬ (+Y)
# ============================================================
@export_group("Верхняя грань (+Y)")
@export var top_texture: Texture2D = preload("res://assets/textures/standard.png"):
	set(value):
		top_texture = value
		_request_rebuild()
@export var top_from := Vector2i(16, 16):
	set(value):
		top_from = value
		_request_rebuild()
@export var top_to := Vector2i(32, 32):
	set(value):
		top_to = value
		_request_rebuild()

# ============================================================
# НИЖНЯЯ ГРАНЬ (-Y)
# ============================================================
@export_group("Нижняя грань (-Y)")
@export var bottom_texture: Texture2D = preload("res://assets/textures/standard.png"):
	set(value):
		bottom_texture = value
		_request_rebuild()
@export var bottom_from := Vector2i(32, 16):
	set(value):
		bottom_from = value
		_request_rebuild()
@export var bottom_to := Vector2i(48, 32):
	set(value):
		bottom_to = value
		_request_rebuild()

var _rebuild_queued := false

func _ready() -> void:
	_rebuild()

func _request_rebuild() -> void:
	if is_inside_tree() and not _rebuild_queued:
		_rebuild_queued = true
		call_deferred("_rebuild")

func _rebuild() -> void:
	_rebuild_queued = false
	var half := box_size * 0.5
	var x := half.x
	var y := half.y
	var z := half.z
	var result := ArrayMesh.new()
	_add_face(result, [Vector3(-x, y, z), Vector3(x, y, z), Vector3(x, -y, z), Vector3(-x, -y, z)], Vector3.FORWARD, front_texture, front_from, front_to)
	_add_face(result, [Vector3(x, y, -z), Vector3(-x, y, -z), Vector3(-x, -y, -z), Vector3(x, -y, -z)], Vector3.BACK, back_texture, back_from, back_to)
	_add_face(result, [Vector3(x, y, z), Vector3(x, y, -z), Vector3(x, -y, -z), Vector3(x, -y, z)], Vector3.RIGHT, right_texture, right_from, right_to)
	_add_face(result, [Vector3(-x, y, -z), Vector3(-x, y, z), Vector3(-x, -y, z), Vector3(-x, -y, -z)], Vector3.LEFT, left_texture, left_from, left_to)
	_add_face(result, [Vector3(-x, y, -z), Vector3(x, y, -z), Vector3(x, y, z), Vector3(-x, y, z)], Vector3.UP, top_texture, top_from, top_to)
	_add_face(result, [Vector3(-x, -y, z), Vector3(x, -y, z), Vector3(x, -y, -z), Vector3(-x, -y, -z)], Vector3.DOWN, bottom_texture, bottom_from, bottom_to)
	mesh = result
	material_override = null 
	update_configuration_warnings()

func _add_face(result: ArrayMesh, corners: Array, normal: Vector3, texture: Texture2D, pixel_from: Vector2i, pixel_to: Vector2i) -> void:
	var uv := [Vector2.ZERO, Vector2.RIGHT, Vector2.ONE, Vector2.DOWN]
	if texture != null and texture.get_width() > 0 and texture.get_height() > 0:
		var width := texture.get_width()
		var height := texture.get_height()
		var from_x := clampi(mini(pixel_from.x, pixel_to.x), 0, width - 1)
		var to_x := clampi(maxi(pixel_from.x, pixel_to.x), from_x + 1, width)
		var from_y := clampi(mini(pixel_from.y, pixel_to.y), 0, height - 1)
		var to_y := clampi(maxi(pixel_from.y, pixel_to.y), from_y + 1, height)
		# Полпикселя внутри границы не даёт соседним клеткам затекать на грань.
		var u0 := (float(from_x) + 0.5) / float(width)
		var u1 := (float(to_x) - 0.5) / float(width)
		var v0 := (float(from_y) + 0.5) / float(height)
		var v1 := (float(to_y) - 0.5) / float(height)
		uv = [Vector2(u0, v0), Vector2(u1, v0), Vector2(u1, v1), Vector2(u0, v1)]
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var uvs := PackedVector2Array()
	for index in [0, 1, 2, 0, 2, 3]:
		vertices.append(corners[index])
		normals.append(normal)
		uvs.append(uv[index])
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	result.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var material := StandardMaterial3D.new()
	material.albedo_texture = texture
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	result.surface_set_material(result.get_surface_count() - 1, material)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	_check_face(warnings, "Передняя", front_texture, front_from, front_to)
	_check_face(warnings, "Задняя", back_texture, back_from, back_to)
	_check_face(warnings, "Правая", right_texture, right_from, right_to)
	_check_face(warnings, "Левая", left_texture, left_from, left_to)
	_check_face(warnings, "Верхняя", top_texture, top_from, top_to)
	_check_face(warnings, "Нижняя", bottom_texture, bottom_from, bottom_to)
	return warnings

func _check_face(warnings: PackedStringArray, title: String, texture: Texture2D, pixel_from: Vector2i, pixel_to: Vector2i) -> void:
	if texture == null:
		warnings.append(title + " грань: выберите PNG.")
	elif pixel_from.x < 0 or pixel_from.y < 0 or pixel_to.x <= pixel_from.x or pixel_to.y <= pixel_from.y or pixel_to.x > texture.get_width() or pixel_to.y > texture.get_height():
		warnings.append(title + " грань: проверьте координаты, они должны быть внутри изображения, а «До» больше «От».")
