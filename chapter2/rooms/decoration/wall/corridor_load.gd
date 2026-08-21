extends Node3D

@export var next_corridor_scene: PackedScene
var is_loading = false

func _ready() -> void:
	if is_in_group("corridorLoad_exit"):
		$wallGates.blocking()
		$wallGates2.unlocking()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and not is_loading and not is_in_group("corridorLoad_exit"):
		$MeshInstance3D/smoke.emitting = true
		$MeshInstance3D2/smoke.emitting = true
		$MeshInstance3D3/smoke.emitting = true
		$MeshInstance3D4/smoke.emitting = true
		$wallGates.blocking()
		await get_tree().create_timer(2).timeout
		_teleport_player(body)

func _teleport_player(player: Node3D) -> void:
	is_loading = true
	var current_exit_pos = global_position
	var current_region = get_parent()
	var root_node = current_region.get_parent()
	var new_region_instance = next_corridor_scene.instantiate()
	root_node.add_child(new_region_instance)
	await get_tree().process_frame
	var exit_nodes = new_region_instance.get_tree().get_nodes_in_group("corridorLoad_exit")
	var new_corridor = exit_nodes[0] if exit_nodes.size() > 0 else null
	if new_corridor:
		var entrance_pos = new_corridor.global_position
		var delta = entrance_pos - current_exit_pos
		player.global_position += delta
	else:
		push_warning("ты не забыл про corridorLoad_exit?")
	root_node.remove_child(current_region)
	current_region.queue_free()
	is_loading = false
