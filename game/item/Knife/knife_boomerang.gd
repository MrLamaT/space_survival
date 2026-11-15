extends Node3D

const GEOMETRY_MASK := 4 | 8 | 32 # main, Doors, floor
const ENEMY_MASK := 16
const CONTACT_GAP := 0.008
const FLOOR_NORMAL_Y := 0.65
const PREVIEW_STEP := 1.0 / 60.0

const DIRECT_DAMAGE := 20
const FIRST_BOUNCE_DAMAGE := 30
const SECOND_BOUNCE_DAMAGE := 30

const FLIGHT_SPEED := 25.0
const FLIGHT_TIME := 3.25
const GRAVITY := Vector3(0.0, -5.0, 0.0)
const MAX_BOUNCES := 10
const BOUNCE_SPEED_FACTOR := 0.85

const ASSIST_RANGE := 9.0
const ASSIST_ANGLE := 32.0
const FLOOR_ASSIST_YAW := 42.0
const FLOOR_ASSIST_PITCH := 55.0

const TRAIL_TIME := 0.15
const TRAIL_WIDTH := 0.09
const TRAIL_COLOR := Color(0.36, 0.88, 1.0)
const SPIN_SPEED := 14.0

var _wall_query := PhysicsRayQueryParameters3D.new()
var _camera: Camera3D
var _spawn_origin := Vector3.ZERO
var _spawn_target := Vector3.ZERO
var _spawn_pending := false
var _velocity := Vector3.ZERO
var _bounce_count := 0
var _age := 0.0
var _flying := false
var _hit_enemies: Dictionary = {}
var _enemy_overlap_query := PhysicsShapeQueryParameters3D.new()

var _trail_points := PackedVector3Array()
var _trail_times := PackedFloat32Array()

@onready var visual: Node3D = $BladePivot
@onready var _sweep: ShapeCast3D = $Sweep
@onready var _trail: MeshInstance3D = $Trail
@onready var _trail_mesh: ImmediateMesh = _trail.mesh as ImmediateMesh
@onready var _sphere: SphereShape3D = _sweep.shape as SphereShape3D

func _ready() -> void:
	set_physics_process(false)
	_sweep.global_transform = Transform3D.IDENTITY
	_trail.global_transform = Transform3D.IDENTITY
	_wall_query.collision_mask = GEOMETRY_MASK
	_wall_query.hit_back_faces = true
	_enemy_overlap_query.shape = _sphere
	_enemy_overlap_query.collision_mask = ENEMY_MASK
	_enemy_overlap_query.collide_with_areas = false
	_enemy_overlap_query.margin = CONTACT_GAP

func launch(camera: Camera3D, start_position: Vector3) -> void:
	_camera = camera
	_spawn_origin = camera.global_position
	_spawn_target = start_position
	_velocity = -camera.global_basis.z.normalized() * FLIGHT_SPEED
	_spawn_pending = true
	visual.hide()
	set_physics_process(true)

func _physics_process(delta: float) -> void:
	if not is_instance_valid(_camera) or Global.IsDying:
		queue_free()
		return
	if _spawn_pending:
		_spawn_pending = false
		if not _place_at_spawn():
			queue_free()
			return
	var previous_age := _age
	_age += delta
	if _flying:
		var flight_step := minf(delta, FLIGHT_TIME - previous_age)
		_advance_flight(flight_step, previous_age)
		if _age >= FLIGHT_TIME:
			_end_flight()
	if _flying:
		_orient_blade()
	_update_trail()
	if not _flying and _trail_points.is_empty():
		queue_free()

func _place_at_spawn() -> bool:
	if _overlaps(_spawn_origin):
		return false
	var motion := _spawn_target - _spawn_origin
	var hit := _trace(_spawn_origin, _spawn_target)
	global_position = _spawn_target
	if not hit.is_empty():
		global_position = _spawn_origin + motion * _safe_fraction(hit, motion)
	_flying = true
	visual.show()
	_record_trail_point(global_position, 0.0)
	return true

func _orient_blade() -> void:
	var forward := _velocity.normalized()
	if forward.is_zero_approx():
		return
	var reference := Vector3.UP
	if absf(forward.dot(reference)) > 0.95:
		reference = Vector3.RIGHT
	var right := forward.cross(reference).normalized()
	var aligned := Basis(right, forward, right.cross(forward))
	var roll := Basis(Vector3.UP, _age * SPIN_SPEED)
	visual.global_basis = aligned * roll

func _advance_flight(duration: float, start_time: float) -> void:
	var remaining := duration
	while remaining > 0.00001 and _flying:
		_refresh_pierced_enemies()
		var start := global_position
		var motion := (_velocity + 0.5 * GRAVITY * remaining) * remaining
		if _overlaps(start, true):
			_end_flight()
			return
		var hit := _trace(start, start + motion)
		if hit.is_empty():
			global_position = start + motion
			_velocity += GRAVITY * remaining
			_record_trail_point(global_position, start_time + duration)
			return
		var contact_fraction := clampf(float(hit["contact_fraction"]), 0.0, 1.0)
		var elapsed := remaining * contact_fraction
		_velocity += GRAVITY * elapsed
		remaining -= elapsed
		var hit_time := start_time + duration - remaining
		var body := hit["collider"] as CollisionObject3D
		if (
			is_instance_valid(body)
			and (body.collision_layer & GEOMETRY_MASK) == 0
			and (body.collision_layer & ENEMY_MASK) != 0
		):
			global_position = start + motion * contact_fraction
			_pierce_enemy(body)
			continue
		global_position = start + motion * _safe_fraction(hit, motion)
		_record_trail_point(global_position, hit_time)
		var normal: Vector3 = hit["normal"]
		if _bounce_count >= MAX_BOUNCES or _velocity.dot(normal) >= 0.0:
			_end_flight()
			return
		_bounce_count += 1
		_refresh_pierced_enemies()
		var reflected := _velocity.bounce(normal) * BOUNCE_SPEED_FACTOR
		_velocity = _assist_bounce(reflected, normal, FLIGHT_TIME - hit_time)

func _pierce_enemy(enemy: CollisionObject3D) -> void:
	var enemy_id := enemy.get_instance_id()
	if _hit_enemies.has(enemy_id):
		return
	var enemy_rid := enemy.get_rid()
	_hit_enemies[enemy_id] = enemy_rid
	_sweep.add_exception_rid(enemy_rid)
	if not _is_live_enemy(enemy):
		return
	var damage := FIRST_BOUNCE_DAMAGE if _bounce_count >= 1 else DIRECT_DAMAGE
	enemy.call("take_damage", damage)

func _refresh_pierced_enemies() -> void:
	if _hit_enemies.is_empty():
		return
	_enemy_overlap_query.transform = Transform3D(Basis.IDENTITY, global_position)
	var space_state := get_world_3d().direct_space_state
	var overlaps := space_state.intersect_shape(_enemy_overlap_query, 64)
	if overlaps.size() >= 64:
		return
	var touching_rids: Dictionary = {}
	for overlap in overlaps:
		touching_rids[overlap["rid"]] = true
	for enemy_id in _hit_enemies.keys():
		var enemy_rid: RID = _hit_enemies[enemy_id]
		if touching_rids.has(enemy_rid):
			continue
		_sweep.remove_exception_rid(enemy_rid)
		_hit_enemies.erase(enemy_id)

func _assist_bounce(
	reflected: Vector3, normal: Vector3, time_left: float
) -> Vector3:
	var speed := reflected.length()
	if speed < 0.01 or time_left <= 0.0:
		return reflected
	var start := global_position
	var heading := reflected / speed
	var flat_heading := Vector3(heading.x, 0.0, heading.z)
	var floor_bounce := normal.y >= FLOOR_NORMAL_Y
	if floor_bounce and flat_heading.length_squared() < 0.01:
		return reflected
	var preview_time := minf(time_left, ASSIST_RANGE / speed)
	var direct_hit := _trace_arc(start, reflected, preview_time)
	var direct_enemy := direct_hit.get("collider") as CollisionObject3D
	if _is_live_enemy(direct_enemy):
		if not _hit_enemies.has(direct_enemy.get_instance_id()):
			return reflected
	var best_velocity := reflected
	var best_alignment := -1.0
	var level_side := Vector3.UP.cross(heading).normalized()
	for node in get_tree().get_nodes_in_group("enemy"):
		var enemy := node as CollisionObject3D
		if not _is_live_enemy(enemy) or _hit_enemies.has(enemy.get_instance_id()):
			continue
		var center := enemy.global_position
		for child in enemy.get_children():
			var shape := child as CollisionShape3D
			if shape != null and not shape.disabled:
				center = shape.global_position
				break
		var points: Array[Vector3] = [
			center,
			center + Vector3.UP * 0.3,
			center - Vector3.UP * 0.3,
			center + level_side * 0.25,
			center - level_side * 0.25,
		]
		for point in points:
			var offset := point - start
			if offset.length_squared() > ASSIST_RANGE * ASSIST_RANGE:
				continue
			var travel_time := _ricochet_travel_time(offset, speed)
			if travel_time <= 0.001 or travel_time > time_left:
				continue
			var gravity_offset := 0.5 * GRAVITY * travel_time * travel_time
			var aim := (offset - gravity_offset) / travel_time
			if aim.dot(normal) <= 0.05:
				continue
			var aim_direction := aim.normalized()
			var alignment := heading.dot(aim_direction)
			if alignment <= best_alignment:
				continue
			if floor_bounce:
				var flat_aim := Vector3(aim_direction.x, 0.0, aim_direction.z)
				if flat_aim.is_zero_approx():
					continue
				if flat_heading.angle_to(flat_aim) > deg_to_rad(FLOOR_ASSIST_YAW):
					continue
				var reflected_pitch := asin(clampf(heading.y, -1.0, 1.0))
				var aim_pitch := asin(clampf(aim_direction.y, -1.0, 1.0))
				if absf(reflected_pitch - aim_pitch) > deg_to_rad(FLOOR_ASSIST_PITCH):
					continue
			elif alignment < cos(deg_to_rad(ASSIST_ANGLE)):
				continue
			var aim_hit := _trace_arc(start, aim, travel_time)
			if aim_hit.get("collider") == enemy:
				best_alignment = alignment
				best_velocity = aim
	return best_velocity

func _ricochet_travel_time(offset: Vector3, speed: float) -> float:
	var distance_squared := offset.length_squared()
	var term := speed * speed + offset.dot(GRAVITY)
	var discriminant := term * term - GRAVITY.length_squared() * distance_squared
	if term <= 0.0 or discriminant < 0.0:
		return 0.0
	return sqrt(2.0 * distance_squared / (term + sqrt(discriminant)))

func _trace_arc(start: Vector3, velocity: Vector3, duration: float) -> Dictionary:
	var steps := maxi(1, ceili(duration / PREVIEW_STEP))
	var previous := start
	for index in range(1, steps + 1):
		var time := duration * float(index) / float(steps)
		var point := start + velocity * time + 0.5 * GRAVITY * time * time
		var hit := _trace(previous, point)
		if not hit.is_empty():
			return hit
		previous = point
	return {}

func _overlaps(point: Vector3, damage_enemies: bool = false) -> bool:
	_sweep.global_position = point
	_sweep.target_position = Vector3.ZERO
	_sweep.force_shapecast_update()
	var enemies: Array[CollisionObject3D] = []
	for index in range(_sweep.get_collision_count()):
		var body := _sweep.get_collider(index) as CollisionObject3D
		if not is_instance_valid(body):
			continue
		if (body.collision_layer & GEOMETRY_MASK) != 0:
			return true
		if damage_enemies and (body.collision_layer & ENEMY_MASK) != 0:
			enemies.append(body)
	for enemy in enemies:
		if is_instance_valid(enemy) and not enemy.is_queued_for_deletion():
			_pierce_enemy(enemy)
	return false

func _trace(from: Vector3, to: Vector3) -> Dictionary:
	var motion := to - from
	var distance := motion.length()
	if distance < 0.00001:
		return {}
	var sphere_hit := _trace_sphere(from, motion)
	_wall_query.from = from
	_wall_query.to = to
	var wall_hit := get_world_3d().direct_space_state.intersect_ray(_wall_query)
	if wall_hit.is_empty():
		return sphere_hit
	var point: Vector3 = wall_hit["position"]
	var normal: Vector3 = wall_hit["normal"]
	var direction := motion / distance
	if normal.dot(direction) > 0.0:
		normal = -normal
	var ray_fraction := clampf(from.distance_to(point) / distance, 0.0, 1.0)
	if not sphere_hit.is_empty():
		if float(sphere_hit["contact_fraction"]) <= ray_fraction:
			return sphere_hit
	var approach := maxf(-direction.dot(normal), 0.001)
	var contact := maxf(0.0, ray_fraction - _sphere.radius / (distance * approach))
	return {
		"safe_fraction": contact,
		"contact_fraction": contact,
		"normal": normal,
		"collider": wall_hit["collider"],
	}

func _trace_sphere(from: Vector3, motion: Vector3) -> Dictionary:
	_sweep.global_position = from
	_sweep.target_position = motion
	_sweep.force_shapecast_update()
	var safe := _sweep.get_closest_collision_safe_fraction()
	if not _sweep.is_colliding() and safe >= 1.0:
		return {}
	var normal := Vector3.ZERO
	var collider: Object = null
	var best_opposition: float = -INF
	var direction := motion.normalized()
	for index in range(_sweep.get_collision_count()):
		var candidate := _sweep.get_collision_normal(index)
		var opposition := -direction.dot(candidate)
		if opposition > best_opposition:
			best_opposition = opposition
			normal = candidate
			collider = _sweep.get_collider(index)
	return {
		"safe_fraction": safe,
		"contact_fraction": _sweep.get_closest_collision_unsafe_fraction(),
		"normal": normal,
		"collider": collider,
	}

func _safe_fraction(hit: Dictionary, motion: Vector3) -> float:
	var safe: float = hit["safe_fraction"]
	return maxf(0.0, safe - CONTACT_GAP / motion.length())

func _is_live_enemy(body: CollisionObject3D) -> bool:
	return (
		is_instance_valid(body)
		and not body.is_queued_for_deletion()
		and body.is_in_group("enemy")
		and body.has_method("take_damage")
		and body.get("is_dead") != true
		and body.get("is_dying") != true
	)

func _end_flight() -> void:
	_flying = false
	visual.hide()

func _record_trail_point(point: Vector3, time: float) -> void:
	_trail_points.append(point)
	_trail_times.append(time)

func _update_trail() -> void:
	while not _trail_times.is_empty() and _age - _trail_times[0] >= TRAIL_TIME:
		_trail_times.remove_at(0)
		_trail_points.remove_at(0)
	_trail_mesh.clear_surfaces()
	if _trail_points.size() < 2:
		return
	_trail_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	for index in range(_trail_points.size()):
		var point := _trail_points[index]
		var before := _trail_points[maxi(0, index - 1)]
		var after := _trail_points[mini(_trail_points.size() - 1, index + 1)]
		var tangent := (after - before).normalized()
		var side := tangent.cross(_camera.global_position - point).normalized()
		if side.is_zero_approx():
			side = _camera.global_basis.x.normalized()
		var point_age := _age - _trail_times[index]
		var opacity := clampf(1.0 - point_age / TRAIL_TIME, 0.0, 1.0)
		var half_width := TRAIL_WIDTH * 0.5 * opacity
		var color := Color(TRAIL_COLOR, opacity)
		_trail_mesh.surface_set_color(color)
		_trail_mesh.surface_add_vertex(point - side * half_width)
		_trail_mesh.surface_set_color(color)
		_trail_mesh.surface_add_vertex(point + side * half_width)
	_trail_mesh.surface_end()
