extends Node3D

var _pierce_left: int = 1
var damage: int = 28
const BOOM_SCENE := preload("res://game/item/Boom_projectile/Boom_projectile.tscn")

func shoot(dir: Vector3, _spd: float):
	if dir.length() < 0.01:
		return
	var up_vector = Vector3.UP
	if abs(dir.normalized().dot(Vector3.UP)) > 0.99:
		up_vector = Vector3.FORWARD
	look_at(global_position + dir.normalized(), up_vector)
	rotate_object_local(Vector3.UP, -PI / 2)

@onready var ray_cast = $RayCast3D

func _physics_process(_delta: float) -> void:
	if _pierce_left <= 0:
		queue_free()
		return
	ray_cast.force_raycast_update()
	if not ray_cast.is_colliding():
		return
	var collider = ray_cast.get_collider()
	if collider == null or not is_instance_valid(collider) or collider.is_queued_for_deletion():
		return
	if collider.has_method("take_damage"):
		collider.take_damage(damage)
	_spawn_boom()
	_pierce_left -= 1
	ray_cast.add_exception(collider)
	ray_cast.force_raycast_update()

func _spawn_boom() -> void:
	var boom = BOOM_SCENE.instantiate()
	boom.impulse = true
	get_tree().current_scene.add_child(boom)
	boom.global_position = ray_cast.get_collision_point()

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	queue_free() 
