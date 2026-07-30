extends Area3D

@export var Gates: Array[Node3D]
@export var sound = true
@export var checkpoint = true
@export var new_min_y = false
@export var target_node: NodePath = ""
@export var trigger_id = ""
var is_active = true
var current_wave = 0
var SpawnAudio = false

func _ready() -> void:
	$MeshInstance3D.queue_free()
	$MeshInstance3D2.queue_free()
	$MeshInstance3D3.queue_free()

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and is_active:
		start_wave()
		if Gates.size() > 0:
			for gate in Gates:
				gate.blocking()
			$Timer.start()
		if checkpoint:
			Global.game_settings["checkpoint"] = global_position
		if new_min_y:
			Global.game_settings["min_y"] = global_position.y - 5
		if target_node:
			var target = get_node(target_node)
			if target.has_method("activate_trigger"):
				target.activate_trigger(trigger_id)
		is_active = false

func start_wave() -> void:
	if !SpawnAudio and sound:
		$AudioStreamPlayer3D.pitch_scale = randf_range(1.9, 2.1)
		$AudioStreamPlayer3D.play()
		SpawnAudio = true
	var markers = find_children("*", "Marker3D", true, false)
	var wave_started = false
	for marker in markers:
		if marker.has_method("spawn") and marker["numberWave"] == current_wave:
			if Gates.size() > 0:
				# Режим с воротами: враги с ключом (обязательные для победы)
				marker.spawn("key")
				wave_started = true
			else:
				# Режим без ворот: обычные враги (не блокируют проход)
				marker.spawn("none")
				wave_started = true
	if not wave_started and current_wave != 0:
		_on_wave_complete()

func _on_wave_complete() -> void:
	$Timer.stop()
	for gate in Gates:
		gate.unlocking()

func _on_timer_timeout() -> void:
	var enemy_nodes = get_tree().get_nodes_in_group("enemy_wave")
	var nextbots = get_tree().get_nodes_in_group("nextbot")
	var only_nextbots_left = true
	for enemy in enemy_nodes:
		if not enemy in nextbots:
			only_nextbots_left = false
			break
	if only_nextbots_left and enemy_nodes.size() > 0:
		for enemy in enemy_nodes:
			if enemy.has_method("take_damage"):
				enemy.take_damage(999999)
	else:
		print("enemy_wave: ", enemy_nodes.size())
		if enemy_nodes.size() == 0:
			current_wave += 1
			start_wave()
