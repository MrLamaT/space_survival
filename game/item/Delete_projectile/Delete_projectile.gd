extends Node3D

var world = Global.get_world(Global.game_settings.word)
var _already_triggered: bool = false
var delete_portal_scene = preload("res://game/wave/DeletePortal.tscn")

func shoot(_dir: Vector3, _spd: float):
	pass

func spawn_delete_portal(Pposition: Vector3):
	var portal = delete_portal_scene.instantiate()
	get_tree().root.add_child(portal)
	portal.global_position = Pposition

@onready var ray_cast = $RayCast3D

func _physics_process(_delta: float) -> void:
	if ray_cast.is_colliding() and not _already_triggered:
		var collider = ray_cast.get_collider()
		if collider is Node3D and (collider.is_in_group("enemy") or collider.is_in_group("prop") or collider.is_in_group("block")):
			_already_triggered = true
			var delete_position = collider.global_position
			spawn_delete_portal(delete_position)
			collider.queue_free()
			queue_free()

func _on_timer_timeout() -> void:
	queue_free() 
