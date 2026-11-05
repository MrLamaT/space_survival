class_name SeamlessPortal
extends Node3D

const PORTAL_LAYER := 20
const MOTION_OWNER := &"seamless_portal_motion_owner"
const TRANSIT_FRAME := &"seamless_portal_transit_frame"

@export var exit_portal: SeamlessPortal
@export_range(0.25, 1.0, 0.05) var render_scale := 0.75

# Время выравнивания горизонта после выхода.
@export_range(0.05, 2.0, 0.05) var camera_level_time := 0.3

# Ускорение подруливания в воздухе после переноса.
@export_range(0.0, 30.0, 0.5) var air_steering := 5.0

# Дополнительный зазор между капсулой и плоскостью выхода.
@export_range(0.001, 0.2, 0.001) var exit_clearance := 0.03

@onready var _surface: MeshInstance3D = $Surface
@onready var _portal_view: SubViewport = $PortalView
@onready var _portal_camera: Camera3D = $PortalView/PortalCamera

# Тип Variant нужен для обращения к полям твоего player.gd.
var _player: Variant = null
var _camera: Camera3D
var _head: Node3D

var _camera_before := Vector3.ZERO
var _sample_valid := false

var _saved_accel := 0.0
var _saved_slide_accel := 0.0
var _acceleration_overridden := false

var _roll_offset := 0.0
var _roll_time_left := 0.0


# Выполняет подготовку до _physics_process() игрока.
class BeforePlayer:
	extends Node

	var portal: SeamlessPortal

	func _physics_process(delta: float) -> void:
		portal._before_player(delta)


func _ready() -> void:
	process_priority = 100
	process_physics_priority = 100

	var before := BeforePlayer.new()
	before.name = "BeforePlayer"
	before.portal = self
	before.process_physics_priority = -100
	add_child(before)

	_portal_view.world_3d = get_world_3d()
	_portal_camera.make_current()

	var material := _surface.material_override as ShaderMaterial
	if material == null:
		push_error("Surface должен иметь ShaderMaterial в Material Override.")
		return

	material = material.duplicate() as ShaderMaterial
	_surface.material_override = material
	material.set_shader_parameter(
		"portal_texture",
		_portal_view.get_texture()
	)


func _find_player() -> void:
	if is_instance_valid(_player):
		return

	_sample_valid = false
	_player = get_tree().get_first_node_in_group("player")

	if not is_instance_valid(_player):
		return

	_camera = _player.get_node_or_null("head/Camera3D") as Camera3D
	_head = _player.get_node_or_null("head") as Node3D


func _owns_motion() -> bool:
	if not is_instance_valid(_player):
		return false
	if not _player.has_meta(MOTION_OWNER):
		return false
	return _player.get_meta(MOTION_OWNER) == self


func _before_player(delta: float) -> void:
	_find_player()
	_sample_valid = false

	if not is_instance_valid(_player):
		return
	if not is_instance_valid(_camera) or not is_instance_valid(_head):
		return
	if not _player.is_physics_processing():
		return

	_camera_before = _camera.global_position
	_sample_valid = true

	if not _owns_motion():
		return

	# Новое действие игрока завершает сохранение портальной инерции.
	var starts_action := (
		Input.is_action_just_pressed("+shift")
		or Input.is_action_just_pressed("+crouch")
	)

	if (
		_player.is_on_floor()
		or not _player.can_move()
		or not _player.affected_by_gravity
		or starts_action
	):
		_release_motion()
		return

	# Подруливаем, сохраняя доступную горизонтальную скорость.
	var input := Input.get_vector("+a", "+d", "+w", "+s")
	var wish := _head.global_basis * Vector3(input.x, 0.0, input.y)
	wish.y = 0.0

	var horizontal := Vector3(
		_player.velocity.x,
		0.0,
		_player.velocity.z
	)

	if not wish.is_zero_approx():
		var speed_limit := maxf(horizontal.length(), float(_player.SPEED))
		horizontal += wish.normalized() * air_steering * delta
		horizontal = horizontal.limit_length(speed_limit)

	_player.velocity.x = horizontal.x
	_player.velocity.z = horizontal.z

	# Штатная гравитация продолжает работать.
	# На этот физический кадр отключаем торможение по XZ.
	_saved_accel = float(_player.accel)
	_saved_slide_accel = float(_player.slide_jump_air_accel)
	_player.accel = 0.0
	_player.slide_jump_air_accel = 0.0
	_acceleration_overridden = true


func _physics_process(_delta: float) -> void:
	_restore_acceleration()

	if _owns_motion() and _player.is_on_floor():
		_release_motion()

	if not _sample_valid or not is_instance_valid(exit_portal):
		return
	if not is_instance_valid(_player) or not is_instance_valid(_camera):
		return
	if not _player.can_move() or _player.cam != _camera:
		return
	if get_viewport().get_camera_3d() != _camera:
		return

	# Несколько порталов не должны переносить игрока в одном кадре.
	var frame := Engine.get_physics_frames()
	if int(_player.get_meta(TRANSIT_FRAME, -1)) == frame:
		return

	var before := _surface.to_local(_camera_before)
	var after := _surface.to_local(_camera.global_position)

	# Проход с лицевой стороны, локальная +Z.
	if before.z <= 0.0 or after.z > 0.0:
		return

	var quad := _surface.mesh as QuadMesh
	if quad == null:
		return

	var fraction := before.z / (before.z - after.z)
	var intersection := before.lerp(after, fraction)
	var half_size := quad.size * 0.5

	if (
		absf(intersection.x) > half_size.x
		or absf(intersection.y) > half_size.y
	):
		return

	_teleport_player(frame)


func _passage_transform() -> Transform3D:
	var half_turn := Transform3D(
		Basis(Vector3.UP, PI),
		Vector3.ZERO
	)
	return (
		exit_portal._surface.global_transform
		* half_turn
		* _surface.global_transform.affine_inverse()
	)


func _teleport_player(frame: int) -> void:
	var passage := _passage_transform()
	var passage_basis := passage.basis.orthonormalized()

	var target_camera := passage * _camera.global_transform
	var target_velocity: Vector3 = passage_basis * _player.velocity

	# Отменяем действия, которые на следующем кадре
	# принудительно переписали бы перенесённую скорость.
	_player.cancel_dash()
	_player.stop_slam()
	_player.is_slide_jumping = false
	_player.falling_fast = false
	_player.update_running_speed()
	_player.get_node("leg_damage/CollisionShape3D").set_deferred(
		"disabled", true
	)

	# Раскладываем новое направление камеры на yaw, pitch и roll.
	var angles := target_camera.basis.orthonormalized().get_euler(
		EULER_ORDER_YXZ
	)

	_head.global_rotation = Vector3(0.0, angles.y, 0.0)
	_camera.rotation = Vector3(
		clampf(angles.x, deg_to_rad(-89.0), deg_to_rad(89.0)),
		0.0,
		angles.z
	)

	# Капсула остаётся вертикальной.
	# Сначала совмещаем камеру с преобразованной точкой выхода.
	_player.global_position += (
		target_camera.origin - _camera.global_position
	)

	_push_capsule_out()

	_player.velocity = target_velocity
	_player.set_meta(TRANSIT_FRAME, frame)

	# Передаём управление инерцией и выравниванием этому порталу.
	var previous_owner: Variant = null
	if _player.has_meta(MOTION_OWNER):
		previous_owner = _player.get_meta(MOTION_OWNER)
	if is_instance_valid(previous_owner) and previous_owner != self:
		previous_owner._roll_time_left = 0.0

	_player.set_meta(MOTION_OWNER, self)

	_roll_offset = wrapf(
		angles.z - deg_to_rad(float(_player.current_tilt)),
		-PI,
		PI
	)
	_roll_time_left = camera_level_time

	# Рука в твоём проекте отдельно догоняет камеру.
	# Переставляем её сразу, чтобы оружие не летело через уровень.
	var hand := _player.get_node("hand_position") as Node3D
	var target := _player.get_node("head/Camera3D/HandTarget") as Node3D
	hand.global_transform = target.global_transform

	_player.reset_physics_interpolation()


func _push_capsule_out() -> void:
	var collision := _player.get_node("CollisionShape3D") as CollisionShape3D
	var capsule := collision.shape as CapsuleShape3D
	if capsule == null:
		return

	var normal := exit_portal._surface.global_basis.z.normalized()
	var shape_basis := collision.global_basis
	var shape_scale := shape_basis.get_scale().abs()
	var axis := shape_basis.y.normalized()

	# Проекция вертикальной капсулы на нормаль выхода.
	var radius := capsule.radius * maxf(shape_scale.x, shape_scale.z)
	var half_segment := maxf(
		capsule.height * 0.5 - capsule.radius,
		0.0
	) * shape_scale.y
	var extent := radius + half_segment * absf(normal.dot(axis))

	var distance := normal.dot(
		collision.global_position - exit_portal._surface.global_position
	)
	var correction := extent + exit_clearance - distance

	if correction > 0.0:
		_player.global_position += normal * correction


func _restore_acceleration() -> void:
	if not _acceleration_overridden:
		return

	if is_instance_valid(_player):
		_player.accel = _saved_accel
		_player.slide_jump_air_accel = _saved_slide_accel

	_acceleration_overridden = false


func _release_motion() -> void:
	_restore_acceleration()

	if _owns_motion():
		_player.remove_meta(MOTION_OWNER)


func _process(delta: float) -> void:
	# player.gd уже выставил штатный наклон камеры.
	# Добавляем затухающий наклон, оставшийся после портала.
	if is_instance_valid(_player) and is_instance_valid(_camera):
		if _roll_time_left > 0.0:
			_roll_time_left = maxf(0.0, _roll_time_left - delta)
			var weight := _roll_time_left / camera_level_time
			weight = weight * weight * (3.0 - 2.0 * weight)
			_camera.rotation.z = (
				deg_to_rad(float(_player.current_tilt))
				+ _roll_offset * weight
			)

	_update_portal_view()


func _update_portal_view() -> void:
	var main_view := get_viewport()
	var main_camera := main_view.get_camera_3d()

	if main_camera == null or not is_instance_valid(exit_portal):
		_portal_view.render_target_update_mode = SubViewport.UPDATE_DISABLED
		return

	var render_size := Vector2i(
		main_view.get_visible_rect().size * render_scale
	)
	render_size.x = maxi(16, render_size.x)
	render_size.y = maxi(16, render_size.y)

	if _portal_view.size != render_size:
		_portal_view.size = render_size

	_portal_camera.global_transform = (
		_passage_transform() * main_camera.get_camera_transform()
	)
	_portal_camera.keep_aspect = main_camera.keep_aspect
	_portal_camera.environment = main_camera.environment
	_portal_camera.attributes = main_camera.attributes
	_portal_camera.set_perspective(
		main_camera.fov,
		main_camera.near,
		main_camera.far
	)
	_portal_camera.cull_mask = main_camera.cull_mask
	_portal_camera.set_cull_mask_value(PORTAL_LAYER, false)
	_portal_view.render_target_update_mode = SubViewport.UPDATE_ALWAYS


func _exit_tree() -> void:
	_release_motion()
