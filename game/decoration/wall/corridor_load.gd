extends Node3D

@export var isFullSceneLoad: bool = false
@export var next_corridor_scene: PackedScene
var is_loading = false

func _ready() -> void:
	if is_in_group("corridorLoad_exit"):
		$wallGates.blocking()
		$wallGates2.unlocking()
		$Area3D/CollisionShape3D.disabled = true

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and not is_loading and not is_in_group("corridorLoad_exit"):
		$MeshInstance3D/smoke.emitting = true
		$MeshInstance3D2/smoke.emitting = true
		$MeshInstance3D3/smoke.emitting = true
		$MeshInstance3D4/smoke.emitting = true
		$wallGates.blocking()
		await get_tree().create_timer(2).timeout
		if isFullSceneLoad:
			SceneManager.load_scene_with_loading(next_corridor_scene.resource_path)
			return
		_teleport_player(body)
		return

func _teleport_player(player: Node3D) -> void:
	is_loading = true
	if next_corridor_scene == null:
		push_warning("Не назначена next_corridor_scene")
		is_loading = false
		return
	var current_exit_pos = global_position
	var current_region = get_parent()
	var root_node = current_region.get_parent()
	var new_region_instance = next_corridor_scene.instantiate()
	root_node.add_child(new_region_instance)
	await get_tree().process_frame
	var new_corridor: Node3D = null
	for node in get_tree().get_nodes_in_group("corridorLoad_exit"):
		if node is Node3D and (
			node == new_region_instance
			or new_region_instance.is_ancestor_of(node)
		):
			new_corridor = node as Node3D
			break
	if new_corridor == null:
		push_warning("ты не забыл про corridorLoad_exit в новой сцене?")
		new_region_instance.queue_free()
		is_loading = false
		return
	if current_region.is_ancestor_of(player):
		player.reparent(root_node, true)
	var delta = new_corridor.global_position - current_exit_pos
	player.global_position += delta
	root_node.remove_child(current_region)
	current_region.queue_free()
	is_loading = false

func teleport_contents():
	var player = get_tree().get_first_node_in_group("player")
	player.global_position = self.global_position
	Global.game_settings["checkpoint"] = player.global_position
