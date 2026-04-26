extends Area3D

var saved_sky : Sky = null
var world_environment : WorldEnvironment = null
var original_environment : Environment = null

func _ready() -> void:
	world_environment = _find_world_environment_by_name("Skybox")

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		_remove_sky()

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		_restore_sky()

func _find_world_environment_by_name(NodeName: String) -> WorldEnvironment:
	var root = get_tree().root
	return _find_node_recursive(root, NodeName)


func _find_node_recursive(node: Node, target_name: String) -> WorldEnvironment:
	if node.name == target_name:
		return node
	for child in node.get_children():
		var found = _find_node_recursive(child, target_name)
		if found:
			return found
	return null

func _remove_sky() -> void:
	if not world_environment:
		world_environment = _find_world_environment_by_name("Skybox")
		if not world_environment:
			return
	var current_env = world_environment.environment
	if current_env:
		saved_sky = current_env.sky
		original_environment = current_env.duplicate()
		current_env.sky = null

func _restore_sky() -> void:
	if not world_environment:
		world_environment = _find_world_environment_by_name("Skybox")
		if not world_environment:
			return
	var current_env = world_environment.environment
	if current_env and saved_sky:
		current_env.sky = saved_sky
	elif original_environment:
		world_environment.environment = original_environment
