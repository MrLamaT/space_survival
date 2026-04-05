extends Area3D

@export var Gates: Node3D
var is_active = true
var current_wave = 0
var SpawnAudio = false

func _ready() -> void:
	$CSGBox3D.queue_free()

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and is_active:
		start_wave()
		if Gates:
			Gates.BlockSpawn(true)
			$Timer.start()
		is_active = false

func start_wave() -> void:
	if !SpawnAudio:
		$AudioStreamPlayer3D.pitch_scale = randf_range(1.9, 2.1)
		$AudioStreamPlayer3D.play()
		SpawnAudio = true
	var markers = find_children("*", "Marker3D", true, false)
	var wave_started = false
	for marker in markers:
		if marker.has_method("spawn") and marker["numberWave"] == current_wave:
			if Gates:
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
	Gates.unlocking()

func _on_timer_timeout() -> void:
	var enemy_nodes = get_tree().get_nodes_in_group("enemy_wave")
	print("enemy_wale: ", enemy_nodes.size())
	if enemy_nodes.size() == 0:
		current_wave += 1
		start_wave()
