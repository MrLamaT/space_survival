extends RigidBody3D

const EXPLOSION_SCENE := preload(
	"res://game/enemy_projectile/Bomba_projectile/Bomba_projectile.tscn"
)
const RING_SCENE := preload(
	"res://game/enemy_projectile/Ring_projectile/Ring_projectile.tscn"
)

const WAVE_DELAY: float = 2.5

@export_range(1, 5999, 1) var duration_seconds: int = 5

@export_group("Wave mode")
@export var wave_mode: bool = false
@export var Gates: Array[Node3D] = []

@onready var countdown: Timer = $Timer
@onready var display: Label3D = $MeshInstance3D/Label3D
@onready var audio_tick: AudioStreamPlayer3D = $AudioTick

@onready var flash_animation: AnimationPlayer = $FlashLayer/AnimationPlayer

var tick: bool = false
var next_tick_at: float = 0.0
var exploding: bool = false

var _attempt_active: bool = false
var _waves_complete: bool = false
var _waiting_for_respawn: bool = false

var _wave_delay_left: float = 0.0
var _wave_index: int = -1

var _wave_numbers: Array[int] = []
var _markers: Array[Marker3D] = []
var _spawned_enemies: Array[Node3D] = []

func _ready() -> void:
	countdown.one_shot = true
	_update_display(duration_seconds)
	if wave_mode:
		_collect_markers()

func _collect_markers() -> void:
	for node in find_children("*", "Marker3D", true, false):
		if not node.has_method("spawn"):
			continue
		_markers.append(node)
		var wave_number := int(node.get("numberWave"))
		if not _wave_numbers.has(wave_number):
			_wave_numbers.append(wave_number)
	_wave_numbers.sort()

func trigger_interaction() -> void:
	if tick or exploding or _waiting_for_respawn:
		return
	if wave_mode and Global.IsDying:
		return
	if wave_mode:
		if _wave_numbers.is_empty():
			push_warning("%s: внутри бомбы нет маркеров врагов." % name)
			return
		_attempt_active = true
		_waves_complete = false
		_wave_delay_left = WAVE_DELAY
		_wave_index = -1
		_spawned_enemies.clear()
		$AudioSiren.play()
		for gate in Gates:
			if is_instance_valid(gate):
				gate.blocking()
	_start_countdown()
	$AudioStreamPlayer3D.play()

func _start_countdown() -> void:
	exploding = false
	tick = true
	remove_from_group("interactive_objects")
	_update_display(duration_seconds)
	countdown.start(float(duration_seconds))
	next_tick_at = (
		float(duration_seconds) - _tick_interval(duration_seconds)
	)

func _process(delta: float) -> void:
	if wave_mode:
		if _waiting_for_respawn:
			if not Global.IsDying:
				_waiting_for_respawn = false
				_start_countdown()
			return
		if _attempt_active and Global.IsDying:
			if _waves_complete:
				_pause_until_respawn()
			else:
				_reset_failed_attempt()
			return
		if _attempt_active and not exploding:
			_update_waves(delta)
	if not tick:
		return
	var remaining := countdown.time_left
	_update_display(ceili(remaining))
	if remaining > 0.0 and remaining <= next_tick_at:
		audio_tick.play()
		next_tick_at = remaining - _tick_interval(remaining)

func _update_waves(delta: float) -> void:
	if _waves_complete:
		return
	if _wave_index == -1:
		_wave_delay_left -= delta
		if _wave_delay_left <= 0.0:
			_start_next_wave()
		return
	if not _has_wave_enemies():
		_start_next_wave()

func _start_next_wave() -> void:
	_wave_index += 1
	if _wave_index >= _wave_numbers.size():
		_complete_waves()
		return
	var wave_number := _wave_numbers[_wave_index]
	for marker in _markers:
		if not is_instance_valid(marker):
			continue
		if int(marker.get("numberWave")) != wave_number:
			continue
		var enemy: Node3D = marker.spawn("none", true)
		if is_instance_valid(enemy):
			_spawned_enemies.append(enemy)

func _has_wave_enemies() -> bool:
	var alive: Array[Node3D] = []
	for enemy in _spawned_enemies:
		if not is_instance_valid(enemy):
			continue
		if enemy.is_queued_for_deletion():
			continue
		if enemy.get("is_dying") == true:
			continue
		if enemy.get("is_dead") == true:
			continue
		alive.append(enemy)
	if alive.is_empty():
		return false
	for enemy in alive:
		if not enemy.is_in_group("glitchy"):
			return true
	for enemy in alive:
		if enemy.has_method("take_damage"):
			enemy.take_damage(999999)
	return true

func _complete_waves() -> void:
	_waves_complete = true
	$AudioSiren.stop()
	for gate in Gates:
		if is_instance_valid(gate):
			gate.unlocking()

func _reset_failed_attempt() -> void:
	$AudioSiren.stop()
	tick = false
	exploding = false
	_attempt_active = false
	_waves_complete = false
	_waiting_for_respawn = false
	countdown.stop()
	audio_tick.stop()
	for enemy in get_tree().get_nodes_in_group("enemy"):
		enemy.queue_free()
	for enemy in _spawned_enemies:
		if is_instance_valid(enemy):
			if not enemy.is_queued_for_deletion():
				enemy.queue_free()
	_spawned_enemies.clear()
	_wave_index = -1
	_wave_delay_left = 0.0
	_update_display(duration_seconds)
	add_to_group("interactive_objects")

func _pause_until_respawn() -> void:
	$AudioSiren.stop()
	tick = false
	countdown.stop()
	audio_tick.stop()
	_waiting_for_respawn = true
	_update_display(duration_seconds)

func _on_timer_timeout() -> void:
	detonate()

func detonate() -> void:
	if exploding:
		return
	if wave_mode and not _attempt_active:
		return
	$AudioSiren.stop()
	exploding = true
	tick = false
	countdown.stop()
	remove_from_group("interactive_objects")
	_explode.call_deferred()

func _explode() -> void:
	_update_display(0)
	if wave_mode:
		_wave_explosion()
		return
	var explosion := EXPLOSION_SCENE.instantiate() as Node3D
	get_tree().current_scene.add_child(explosion)
	explosion.global_position = global_position
	var ring := RING_SCENE.instantiate() as Node3D
	get_tree().current_scene.add_child(ring)
	ring.global_position = global_position
	$AudioBoom.play()
	visible = false

func _wave_explosion() -> void:
	if not _waves_complete and _wave_index >= 0:
		if not _has_wave_enemies():
			if _wave_index == _wave_numbers.size() - 1:
				_complete_waves()
	_show_white_flash()
	$AudioBoom.play()
	if _waves_complete:
		_pause_until_respawn()
	else:
		_reset_failed_attempt()
	var player := get_tree().get_first_node_in_group("player")
	if is_instance_valid(player):
		player.health_system.player_death()

func _show_white_flash() -> void:
	flash_animation.stop()
	flash_animation.play("flash")
	flash_animation.advance(0.0)

func _tick_interval(remaining: float) -> float:
	if remaining <= 3.0:
		return 0.25
	if remaining <= 10.0:
		return 0.5
	return 1.0

func _update_display(seconds: int) -> void:
	var minutes := floori(seconds / 60.0)
	display.text = "%02d:%02d" % [minutes, seconds % 60]

func _on_audio_boom_finished() -> void:
	if not wave_mode:
		queue_free()

func _on_audio_siren_finished() -> void:
	if wave_mode and tick and not exploding and not _waves_complete:
		$AudioSiren.play()
