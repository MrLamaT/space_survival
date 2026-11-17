extends Node3D

@export var max_radiation_level: float = 3.0
@export var min_distance: float = 2.0   # Минимальное расстояние для максимальной радиации
@export var max_distance: float = 15.0  # Максимальное расстояние для отсутствия радиации
@export var influence_radius: float = 20.0  # Радиус влияния (оптимизация)
@export var geiger_interval_min: float = 0.1   # Минимальный интервал при уровне 3 (быстро)
@export var geiger_interval_max: float = 2.0   # Максимальный интервал при уровне 1 (медленно)

var player: Node3D = null
var current_radiation: float = 0.0
var radiation_level: float = 0.0
var is_active: bool = true
var previous_radiation_level: float = -1.0  # Для отслеживания изменений

static var all_radiation_levels: Dictionary = {}
static var global_radiation_level: float = 0.0

var geiger_timer: float = 0.0
var geiger_interval: float = 2.0

@onready var geiger: AudioStreamPlayer2D = $geiger

func _ready():
	player = get_tree().get_first_node_in_group("player")
	var trigger_id = get_instance_id()
	all_radiation_levels[trigger_id] = 0.0
	if geiger:
		geiger.stop()
		geiger_interval = geiger_interval_max

func _process(delta):
	if player == null or not is_active:
		return
	var distance = global_position.distance_to(player.global_position)
	if distance > influence_radius:
		if current_radiation > 0:
			current_radiation = 0.0
			update_global_radiation()
		return
	if distance >= max_distance:
		current_radiation = 0.0
	else:
		var normalized_distance = clamp((distance - min_distance) / (max_distance - min_distance), 0.0, 1.0)
		current_radiation = max_radiation_level * (1.0 - normalized_distance)
		if distance <= min_distance:
			current_radiation = max_radiation_level
	update_global_radiation()
	update_geiger_sound(delta)

func update_global_radiation():
	var trigger_id = get_instance_id()
	all_radiation_levels[trigger_id] = current_radiation
	var max_radiation = 0.0
	for key in all_radiation_levels:
		if all_radiation_levels[key] > max_radiation:
			max_radiation = all_radiation_levels[key]
	global_radiation_level = max_radiation

func update_geiger_sound(delta):
	if not geiger:
		return
	var local_level = get_local_radiation_level()
	if local_level < 0.1:
		geiger.stop()
		geiger_timer = 0.0
		return
	var normalized_level = clamp((local_level - 1.0) / 2.0, 0.0, 1.0)
	geiger_interval = geiger_interval_max - (geiger_interval_max - geiger_interval_min) * normalized_level
	geiger_timer += delta
	if geiger_timer >= geiger_interval:
		geiger_timer = 0.0
		geiger.play()

func get_local_radiation_level() -> float:
	return current_radiation

func _exit_tree():
	var trigger_id = get_instance_id()
	if all_radiation_levels.has(trigger_id):
		all_radiation_levels.erase(trigger_id)
	update_global_radiation()
	if geiger and geiger.playing:
		geiger.stop()
