extends RigidBody3D

const EXPLOSION_SCENE := preload("res://game/enemy_projectile/Bomba_projectile/Bomba_projectile.tscn")
const RING_SCENE := preload(
	"res://game/enemy_projectile/Ring_projectile/Ring_projectile.tscn"
)

@export_range(1, 5999, 1) var duration_seconds: int = 5

@onready var countdown: Timer = $Timer
@onready var display: Label3D = $MeshInstance3D/Label3D
@onready var audio_tick: AudioStreamPlayer3D = $AudioTick

var tick := false
var next_tick_at := 0.0
var exploding := false

func _ready() -> void:
	countdown.one_shot = true
	_update_display(duration_seconds)

func trigger_interaction() -> void:
	if tick or exploding:
		return
	tick = true
	remove_from_group("interactive_objects")
	_update_display(duration_seconds)
	$AudioStreamPlayer3D.play()
	countdown.start(float(duration_seconds))
	next_tick_at = float(duration_seconds) - _tick_interval(duration_seconds)

func _process(_delta: float) -> void:
	if not tick:
		return
	var remaining := countdown.time_left
	_update_display(ceili(remaining))
	if remaining > 0.0 and remaining <= next_tick_at:
		audio_tick.play()
		next_tick_at = remaining - _tick_interval(remaining)

func _explode() -> void:
	_update_display(0)
	tick = false
	var explosion := EXPLOSION_SCENE.instantiate() as Node3D
	get_tree().current_scene.add_child(explosion)
	explosion.global_position = global_position
	var ring = RING_SCENE.instantiate()
	get_tree().current_scene.add_child(ring)
	ring.global_position = global_position
	queue_free()

func _tick_interval(remaining: float) -> float:
	if remaining <= 3.0:
		return 0.25
	if remaining <= 10.0:
		return 0.5
	return 1.0

func _update_display(seconds: int) -> void:
	var minutes := floori(seconds / 60.0)
	display.text = "%02d:%02d" % [minutes, seconds % 60]

func _on_timer_timeout() -> void:
	detonate()

func detonate() -> void:
	if exploding:
		return
	exploding = true
	tick = false
	countdown.stop()
	remove_from_group("interactive_objects")
	_explode.call_deferred()
