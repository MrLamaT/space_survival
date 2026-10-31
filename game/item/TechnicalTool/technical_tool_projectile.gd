extends Node3D

enum Mode {
	AGGRO,
	FREEZE,
}

@export var mode: Mode = Mode.AGGRO
var _has_hit: bool = false
@onready var ray_cast: RayCast3D = $RayCast3D

func shoot(dir: Vector3, _spd: float) -> void:
	if dir.length() < 0.01:
		return
	var direction := dir.normalized()
	var up_vector := Vector3.UP
	if abs(direction.dot(Vector3.UP)) > 0.99:
		up_vector = Vector3.FORWARD
	look_at(global_position + direction, up_vector)
	rotate_object_local(Vector3.UP, -PI / 2)

func _physics_process(_delta: float) -> void:
	if _has_hit:
		return
	ray_cast.force_raycast_update()
	if not ray_cast.is_colliding():
		return
	var collider = ray_cast.get_collider()
	if not is_instance_valid(collider):
		return
	if collider.is_queued_for_deletion():
		return
	match mode:
		Mode.AGGRO:
			_apply_aggro(collider)
		Mode.FREEZE:
			_apply_freeze(collider)

func _apply_aggro(collider: Object) -> void:
	if not ("enemyTags" in collider):
		return
	if not ("player" in collider):
		return
	_has_hit = true
	collider.set("enemyTags", Global.summon["enemyTags"])
	collider.set("player", null)
	if collider.has_method("start_chasing_player"):
		collider.call("start_chasing_player")

func _apply_freeze(collider: Object) -> void:
	if not ("watch" in collider):
		return
	_has_hit = true
	collider.set("watch", not collider.get("watch"))

func _on_animation_player_animation_finished(
	_anim_name: StringName
) -> void:
	queue_free()
