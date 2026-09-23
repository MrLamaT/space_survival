extends Node3D

var _has_hit: bool = false

func shoot(dir: Vector3, _spd: float):
	if dir.length() < 0.01:
		return
	var up_vector = Vector3.UP
	if abs(dir.normalized().dot(Vector3.UP)) > 0.99:
		up_vector = Vector3.FORWARD
	look_at(global_position + dir.normalized(), up_vector)
	rotate_object_local(Vector3.UP, -PI / 2)

@onready var ray_cast = $RayCast3D

func _physics_process(_delta):
	if _has_hit:
		return
	ray_cast.force_raycast_update()
	if not ray_cast.is_colliding():
		return
	var collider = ray_cast.get_collider()
	if collider == null or not is_instance_valid(collider) or collider.is_queued_for_deletion():
		return
	if not ("watch" in collider):
		return
	collider["watch"] = !collider["watch"]
	_has_hit = true

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	queue_free()
