extends Node3D

var _already_triggered: bool = false
var damage: int = 10

func shoot(_dir: Vector3, _spd: float):
	pass

@onready var ray_cast = $RayCast3D

func _physics_process(_delta: float) -> void:
	if _already_triggered:
		return
	if not ray_cast.is_colliding():
		return
	var collider = ray_cast.get_collider()
	if collider == null or not is_instance_valid(collider):
		queue_free()
		return
	if collider.is_queued_for_deletion():
		queue_free()
		return
	_already_triggered = true
	if collider.has_method("take_damage"):
		collider.take_damage(damage)
	queue_free()

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	queue_free() 
