extends "res://game/wave/BaseWave.gd"

@export var Gates: Array[Node3D]
@export var checkpoint: bool = true
@export var new_min_y: bool = false
@export var target_node: NodePath = ""
@export var trigger_id: String = ""

func _ready() -> void:
	clear_glitchy = true
	$MeshInstance3D.queue_free()
	$MeshInstance3D2.queue_free()
	$MeshInstance3D3.queue_free()

func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("player") or not is_active:
		return
	is_active = false
	start_wave()
	if not Gates.is_empty():
		for gate in Gates:
			gate.blocking()
		wave_timer.start()
	if checkpoint:
		Global.game_settings["checkpoint"] = global_position
	if new_min_y:
		Global.game_settings["min_y"] = global_position.y - 5
	if not target_node.is_empty():
		var target := get_node_or_null(target_node)
		if target != null and target.has_method("activate_trigger"):
			target.activate_trigger(trigger_id)

func _get_spawn_type() -> String:
	return "none" if Gates.is_empty() else "key"

func _on_wave_complete() -> void:
	for gate in Gates:
		gate.unlocking()
