extends Node3D

var damage: int = 4
var max_distance: float = 30.0

var _direction: Vector3 = Vector3.ZERO
var _speed: float = 35.0
var _distance_traveled: float = 0.0
var _started: bool = false
var _finished: bool = false

var _hits_left: int = 2
var _hit_bodies: Dictionary = {}

@onready var area: Area3D = $Area3D

func shoot(direction: Vector3, speed: float) -> void:
	if direction.length_squared() < 0.001 or speed <= 0.0:
		_finish()
		return
	_direction = direction.normalized()
	_speed = speed
	_started = true

func _physics_process(delta: float) -> void:
	if not _started or _finished:
		return
	var distance_left := max_distance - _distance_traveled
	var travel := minf(_speed * delta, distance_left)
	if travel <= 0.0:
		_finish()
		return
	global_position += _direction * travel
	_distance_traveled += travel
	if _distance_traveled >= max_distance:
		_finish()

func _finish() -> void:
	if _finished:
		return
	_finished = true
	hide()
	queue_free()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if not _started or _finished:
		return
	if not is_instance_valid(body):
		return
	if body.is_in_group("player"):
		return
	var body_id := body.get_instance_id()
	if _hit_bodies.has(body_id):
		return
	_hit_bodies[body_id] = true
	var is_enemy := body.is_in_group("enemy")
	if body.has_method("take_damage"):
		body.call("take_damage", damage)
	if not is_enemy:
		_finish()
		return
	_hits_left -= 1
	if _hits_left <= 0:
		_finish()
