extends Area3D

var saved_sky : Sky = null
var world_environment : WorldEnvironment = null
var original_environment : Environment = null

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		_remove_sky()

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		_restore_sky()

func _remove_sky() -> void:
	world_environment = get_tree().get_first_node_in_group("skybox")
	if not world_environment:
		return
	var current_env = world_environment.environment
	if current_env:
		saved_sky = current_env.sky
		original_environment = current_env.duplicate()
		current_env.sky = null

func _restore_sky() -> void:
	if not world_environment:
		return
	var current_env = world_environment.environment
	if current_env and saved_sky:
		current_env.sky = saved_sky
	elif original_environment:
		world_environment.environment = original_environment
