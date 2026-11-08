extends Node3D

const OUTBOUND_DAMAGE: int = 10
const RETURN_DAMAGE: int = 20

const WALL_MASK: int = (1 << 2) | (1 << 3) | (1 << 5)
const WALL_GAP: float = 0.05

var flight_distance: float = 10.0
var outbound_time: float = 0.40
var return_time: float = 0.75
var catch_distance: float = 1.50
var spin_speed: float = 18.0

@onready var visual: Node3D = $handItem
@onready var hit_area: Area3D = $Area3D
@onready var hit_shape: CollisionShape3D = $Area3D/CollisionShape3D

var _camera: Camera3D
var _origin: Vector3
var _turn_point: Vector3
var _returning: bool = false
var _phase_time: float = 0.0
var _spin_angle: float = 0.0
var _hit_bodies: Dictionary = {}

func _ready() -> void:
	set_physics_process(false)

func launch(camera: Camera3D, start_position: Vector3) -> void:
	_camera = camera
	var camera_basis := camera.global_basis.orthonormalized()
	_origin = start_position
	_turn_point = _origin - camera_basis.z * flight_distance
	global_position = _origin
	visual.global_basis = camera_basis
	set_physics_process(true)

func _physics_process(delta: float) -> void:
	if not is_instance_valid(_camera) or Global.IsDying:
		queue_free()
		return
	_phase_time += delta
	_spin_angle += spin_speed * delta
	var camera_basis := _camera.global_basis.orthonormalized()
	visual.global_basis = camera_basis * Basis(Vector3.BACK, _spin_angle)
	var next_position: Vector3
	if _returning:
		var progress := minf(_phase_time / return_time, 1.0)
		var catch_point := _camera.global_position - camera_basis.z * catch_distance
		next_position = _turn_point.lerp(
			catch_point, smoothstep(0.0, 1.0, progress)
		)
	else:
		var progress := minf(_phase_time / outbound_time, 1.0)
		next_position = _origin.lerp(_turn_point, sin(progress * PI * 0.5))
	var wall := _find_wall(global_position, next_position)
	if not wall.is_empty():
		if _returning:
			queue_free()
			return
		var wall_position: Vector3 = wall["position"]
		global_position = wall_position.move_toward(global_position, WALL_GAP)
		_hit_targets()
		_begin_return()
		return
	global_position = next_position
	_hit_targets()
	if _returning:
		if _phase_time >= return_time:
			queue_free()
	elif _phase_time >= outbound_time:
		_begin_return()

func _begin_return() -> void:
	_returning = true
	_turn_point = global_position
	_phase_time = 0.0
	_hit_bodies.clear()

func _find_wall(
	from: Vector3, to: Vector3, excluded_bodies: Array[RID] = []
) -> Dictionary:
	if from.is_equal_approx(to):
		return {}
	var query := PhysicsRayQueryParameters3D.create(
		from, to, WALL_MASK, excluded_bodies
	)
	return get_world_3d().direct_space_state.intersect_ray(query)

func _hit_targets() -> void:
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = hit_shape.shape
	query.transform = hit_shape.global_transform
	query.collision_mask = hit_area.collision_mask
	for hit in get_world_3d().direct_space_state.intersect_shape(query, 64):
		var body := hit["collider"] as CollisionObject3D
		if not is_instance_valid(body) or body.is_queued_for_deletion():
			continue
		if not body.has_method("take_damage"):
			continue
		var body_id := body.get_instance_id()
		if _hit_bodies.has(body_id):
			continue
		if not _find_wall(global_position, body.global_position, [body.get_rid()]).is_empty():
			continue
		_hit_bodies[body_id] = true
		var damage := RETURN_DAMAGE if _returning else OUTBOUND_DAMAGE
		body.call("take_damage", damage)
