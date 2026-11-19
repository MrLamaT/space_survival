extends Node3D

@export var sound: bool = true

var is_active: bool = true
var current_wave: int = 0
var SpawnAudio: bool = false

var clear_glitchy: bool = false

@onready var wave_timer: Timer = $Timer
@onready var wave_audio: AudioStreamPlayer3D = $AudioStreamPlayer3D

func start_wave() -> void:
	_before_wave_start()
	if not SpawnAudio and sound:
		wave_audio.pitch_scale = randf_range(1.9, 2.1)
		wave_audio.play()
		SpawnAudio = true
	var wave_started := false
	var spawn_type := _get_spawn_type()
	for marker in find_children("*", "Marker3D", true, false):
		if not marker.has_method("spawn"):
			continue
		if marker.get("numberWave") != current_wave:
			continue
		marker.spawn(spawn_type)
		wave_started = true
	if not wave_started and current_wave != 0:
		wave_timer.stop()
		_on_wave_complete()

func _on_timer_timeout() -> void:
	var enemies := get_tree().get_nodes_in_group("enemy_wave")
	if clear_glitchy and not enemies.is_empty():
		var only_glitchy_left := true
		for enemy in enemies:
			if not enemy.is_in_group("glitchy"):
				only_glitchy_left = false
				break
		if only_glitchy_left:
			for enemy in enemies:
				if enemy.has_method("take_damage"):
					enemy.take_damage(999999)
			return
	if enemies.is_empty():
		current_wave += 1
		start_wave()

func _get_spawn_type() -> String:
	return "key"

func _before_wave_start() -> void:
	pass

func _on_wave_complete() -> void:
	pass
