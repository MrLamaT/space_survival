# PerformanceMonitor.gd - Расширенный мониторинг производительности 3D
# Версия для Godot 4.7.1 с отслеживанием сцен и детальной диагностикой

extends Node

# Настройки мониторинга
var log_interval: float = 2.0  # Интервал записи в лог (секунды)
const MAX_LOG_ENTRIES: int = 10000  # Максимальное количество записей в логе
const LOG_FILE_PATH: String = "user://performance_log.csv"
const ALERT_LOG_PATH: String = "user://performance_alerts.log"

# Внутренние переменные
var _timer: Timer
var _log_buffer: Array[String] = []
var _alert_buffer: Array[String] = []
var _frame_count: int = 0
var _time_since_last_log: float = 0.0
var _time_since_last_alert: float = 0.0
var _is_initialized: bool = false

# Отслеживание сцен
var _current_scene: String = "unknown"
var _previous_scene: String = ""
var _scene_change_time: float = 0.0
var _scene_stats: Dictionary = {}

# Кэшированные значения для снижения нагрузки
var _last_fps: float = 0.0
var _last_frame_time: float = 0.0
var _last_render_time: float = 0.0
var _last_physics_time: float = 0.0
var _last_draw_calls: int = 0
var _last_primitives: int = 0
var _last_objects: int = 0
var _last_nodes: int = 0
var _last_texture_memory: float = 0.0
var _last_video_memory: float = 0.0
var _last_physics_objects: int = 0
var _last_physics_collisions: int = 0

# Дополнительные метрики
var _peak_primitives: int = 0
var _peak_draw_calls: int = 0
var _peak_objects: int = 0
var _peak_memory: float = 0.0
var _fps_drops: int = 0

func _ready():
	_init_monitor()
	_start_monitoring()
	# Подключаемся к системе сцен
	_get_current_scene()

func _init_monitor():
	# Создаем таймер с низким приоритетом для сбора данных
	_timer = Timer.new()
	_timer.wait_time = 0.5
	_timer.autostart = true
	_timer.timeout.connect(_collect_performance_data)
	add_child(_timer)
	
	# Создаем файлы если их нет
	_create_log_files()
	
	_is_initialized = true

func _create_log_files():
	# Основной лог
	var file = FileAccess.open(LOG_FILE_PATH, FileAccess.READ)
	if file == null:
		var new_file = FileAccess.open(LOG_FILE_PATH, FileAccess.WRITE)
		var header = "timestamp,scene,fps,frame_time_ms,render_time_ms,physics_time_ms,draw_calls,primitives,objects,nodes,texture_memory_mb,video_memory_mb,physics_objects,physics_collisions,process_delta\n"
		new_file.store_string(header)
		new_file.close()
	else:
		file.close()
	
	# Лог предупреждений
	var alert_file = FileAccess.open(ALERT_LOG_PATH, FileAccess.READ)
	if alert_file == null:
		var new_alert = FileAccess.open(ALERT_LOG_PATH, FileAccess.WRITE)
		var alert_header = "timestamp,scene,severity,message,fps,draw_calls,primitives,memory_mb\n"
		new_alert.store_string(alert_header)
		new_alert.close()
	else:
		alert_file.close()

func _start_monitoring():
	set_process(true)
	set_physics_process(false)

func _get_current_scene() -> String:
	var scene = get_tree().current_scene
	if scene:
		var scene_path = scene.scene_file_path
		if scene_path:
			# Извлекаем имя сцены из пути
			var parts = scene_path.split("/")
			if parts.size() > 0:
				var filename = parts[parts.size() - 1]
				_current_scene = filename.replace(".tscn", "").replace(".scn", "")
			else:
				_current_scene = "unknown"
		else:
			_current_scene = scene.name
	else:
		_current_scene = "no_scene"
	
	# Обновляем статистику сцены
	if _current_scene != _previous_scene:
		_scene_change_time = Time.get_unix_time_from_system()
		_previous_scene = _current_scene
		
		# Инициализируем статистику для новой сцены
		if not _scene_stats.has(_current_scene):
			_scene_stats[_current_scene] = {
				"first_visit": _scene_change_time,
				"visit_count": 0,
				"total_time": 0.0,
				"avg_fps": 0.0,
				"peak_primitives": 0,
				"peak_draw_calls": 0,
				"peak_objects": 0,
				"fps_drops": 0
			}
		_scene_stats[_current_scene]["visit_count"] += 1
		
		# Логируем смену сцены
		var msg = "Переход на сцену: %s" % _current_scene
		_add_alert("INFO", msg)
	
	return _current_scene

func _process(delta):
	if not _is_initialized:
		return
	
	# Проверяем смену сцены каждый кадр
	var current_scene = _get_current_scene()
	
	_frame_count += 1
	_time_since_last_log += delta
	_time_since_last_alert += delta
	
	# Обновляем базовую информацию
	_last_fps = Engine.get_frames_per_second()
	_last_frame_time = delta * 1000.0
	
	# Проверяем FPS дропы
	if _last_fps < 30 and _last_fps > 0:
		_fps_drops += 1
		if _time_since_last_alert > 5.0:  # Не спамим
			var msg = "⚠️ Низкий FPS: %.1f на сцене %s" % [_last_fps, _current_scene]
			_add_alert("WARNING", msg)
			_time_since_last_alert = 0.0
			
			# Обновляем статистику
			if _scene_stats.has(_current_scene):
				_scene_stats[_current_scene]["fps_drops"] += 1
	
	# Записываем лог с заданным интервалом
	if _time_since_last_log >= log_interval:
		_write_log_entry()
		_time_since_last_log = 0.0
		
		# Обновляем статистику сцены
		if _scene_stats.has(_current_scene):
			var stats = _scene_stats[_current_scene]
			stats["total_time"] += log_interval
			stats["avg_fps"] = (stats["avg_fps"] * 0.9 + _last_fps * 0.1)
			if _last_primitives > stats["peak_primitives"]:
				stats["peak_primitives"] = _last_primitives
			if _last_draw_calls > stats["peak_draw_calls"]:
				stats["peak_draw_calls"] = _last_draw_calls
			if _last_objects > stats["peak_objects"]:
				stats["peak_objects"] = _last_objects

func _collect_performance_data():
	if not _is_initialized:
		return
	
	# Основные метрики
	var draw_calls_raw = Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
	var primitives_raw = Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)
	var objects_raw = Performance.get_monitor(Performance.OBJECT_COUNT)
	var nodes_raw = Performance.get_monitor(Performance.OBJECT_NODE_COUNT)
	var physics_objects_raw = Performance.get_monitor(Performance.PHYSICS_3D_ACTIVE_OBJECTS)
	var physics_collisions_raw = Performance.get_monitor(Performance.PHYSICS_3D_COLLISION_PAIRS)
	
	_last_draw_calls = int(draw_calls_raw)
	_last_primitives = int(primitives_raw)
	_last_objects = int(objects_raw)
	_last_nodes = int(nodes_raw)
	_last_physics_objects = int(physics_objects_raw)
	_last_physics_collisions = int(physics_collisions_raw)
	
	# Память (в мегабайтах)
	var texture_mem_raw = Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED)
	var video_mem_raw = Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)
	_last_texture_memory = float(texture_mem_raw) / (1024.0 * 1024.0)
	_last_video_memory = float(video_mem_raw) / (1024.0 * 1024.0)
	
	# Время рендеринга и физики
	var render_raw = Performance.get_monitor(Performance.TIME_PROCESS)
	var physics_raw = Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)
	_last_render_time = float(render_raw) * 1000.0
	_last_physics_time = float(physics_raw) * 1000.0
	
	# Обновляем пиковые значения
	if _last_primitives > _peak_primitives:
		_peak_primitives = _last_primitives
	if _last_draw_calls > _peak_draw_calls:
		_peak_draw_calls = _last_draw_calls
	if _last_objects > _peak_objects:
		_peak_objects = _last_objects
	if _last_texture_memory > _peak_memory:
		_peak_memory = _last_texture_memory
	
	# Проверка критических значений
	_check_performance_alerts()

func _check_performance_alerts():
	var alerts = []
	var severity = "WARNING"
	
	# Критические проверки
	if _last_draw_calls > 2000:
		severity = "CRITICAL"
		alerts.append("ОЧЕНЬ МНОГО DRAW CALLS: %d (оптимально <500)" % _last_draw_calls)
	elif _last_draw_calls > 1000:
		alerts.append("Много draw calls: %d (оптимально <500)" % _last_draw_calls)
	
	if _last_primitives > 1000000:
		severity = "CRITICAL"
		alerts.append("ИЗБЫТОЧНАЯ ГЕОМЕТРИЯ: %d примитивов" % _last_primitives)
	elif _last_primitives > 500000:
		alerts.append("Высокая геометрия: %d примитивов" % _last_primitives)
	
	if _last_texture_memory > 500:
		severity = "CRITICAL"
		alerts.append("КРИТИЧЕСКАЯ ПАМЯТЬ ТЕКСТУР: %.1f MB" % _last_texture_memory)
	elif _last_texture_memory > 300:
		alerts.append("Высокое использование памяти: %.1f MB" % _last_texture_memory)
	
	if _last_render_time > 50:
		severity = "CRITICAL"
		alerts.append("ДОЛГИЙ КАДР: %.1f ms" % _last_render_time)
	elif _last_render_time > 30:
		alerts.append("Долгий кадр: %.1f ms" % _last_render_time)
	
	if _last_objects > 8000:
		severity = "CRITICAL"
		alerts.append("СЛИШКОМ МНОГО ОБЪЕКТОВ: %d" % _last_objects)
	elif _last_objects > 5000:
		alerts.append("Много объектов: %d" % _last_objects)
	
	if _last_physics_time > 20:
		severity = "CRITICAL"
		alerts.append("КРИТИЧЕСКОЕ ВРЕМЯ ФИЗИКИ: %.1f ms" % _last_physics_time)
	elif _last_physics_time > 10:
		alerts.append("Высокое время физики: %.1f ms" % _last_physics_time)
	
	# Проверка на утечку памяти (рост более 50 MB за короткое время)
	if _last_texture_memory > 400 and _last_texture_memory - _peak_memory < 0:
		# Проверяем, не было ли резкого скачка
		pass
	
	# Отправка предупреждений
	for alert in alerts:
		_add_alert(severity, alert)
		
		# Дополнительная информация для критических ошибок
		if severity == "CRITICAL":
			var details = "Сцена: %s, Объекты: %d, Узлы: %d, Память: %.1f MB" % [
				_current_scene, _last_objects, _last_nodes, _last_texture_memory
			]
			_add_alert("INFO", "Детали: " + details)

func _add_alert(severity: String, message: String):
	var timestamp = Time.get_datetime_string_from_system()
	var entry = "%s,%s,%s,%s,%.1f,%d,%d,%.1f\n" % [
		timestamp,
		_current_scene,
		severity,
		message,
		_last_fps,
		_last_draw_calls,
		_last_primitives,
		_last_texture_memory
	]
	
	_alert_buffer.append(entry)
	
	# Вывод в консоль
	print("[%s] [%s] [%s] %s" % [timestamp, _current_scene, severity, message])
	
	# Автоматическая запись предупреждений
	if len(_alert_buffer) >= 10:
		_flush_alerts()

func _flush_alerts():
	if _alert_buffer.is_empty():
		return
	
	var file = FileAccess.open(ALERT_LOG_PATH, FileAccess.READ_WRITE)
	if file:
		file.seek_end()
		for entry in _alert_buffer:
			file.store_string(entry)
		file.close()
		_alert_buffer.clear()

func _write_log_entry():
	if len(_log_buffer) >= MAX_LOG_ENTRIES:
		_flush_log()
	
	var timestamp = Time.get_datetime_string_from_system()
	var entry = "%s,%s,%.2f,%.3f,%.3f,%.3f,%d,%d,%d,%d,%.2f,%.2f,%d,%d,%.6f\n" % [
		timestamp,
		_current_scene,
		_last_fps,
		_last_frame_time,
		_last_render_time,
		_last_physics_time,
		_last_draw_calls,
		_last_primitives,
		_last_objects,
		_last_nodes,
		_last_texture_memory,
		_last_video_memory,
		_last_physics_objects,
		_last_physics_collisions,
		_last_frame_time / 1000.0
	]
	
	_log_buffer.append(entry)
	
	if len(_log_buffer) >= 100:
		_flush_log()

func _flush_log():
	if _log_buffer.is_empty():
		return
	
	var file = FileAccess.open(LOG_FILE_PATH, FileAccess.READ_WRITE)
	if file:
		file.seek_end()
		for entry in _log_buffer:
			file.store_string(entry)
		file.close()
		_log_buffer.clear()

func _notification(what):
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST:
			_flush_log()
			_flush_alerts()
			_cleanup()
		NOTIFICATION_CRASH:
			_flush_log()
			_flush_alerts()
		NOTIFICATION_EXIT_TREE:
			_flush_log()
			_flush_alerts()

func _cleanup():
	if _timer:
		_timer.stop()
		_timer.queue_free()
		_timer = null

# ============= ПУБЛИЧНЫЕ МЕТОДЫ =============

func get_log_path() -> String:
	return LOG_FILE_PATH

func get_alert_log_path() -> String:
	return ALERT_LOG_PATH

func get_current_scene_name() -> String:
	return _current_scene

func get_scene_stats(scene_name: String = "") -> Dictionary:
	if scene_name == "":
		scene_name = _current_scene
	return _scene_stats.get(scene_name, {})

func get_all_scene_stats() -> Dictionary:
	return _scene_stats

func get_performance_summary() -> Dictionary:
	return {
		"fps": _last_fps,
		"frame_time_ms": _last_frame_time,
		"render_time_ms": _last_render_time,
		"physics_time_ms": _last_physics_time,
		"draw_calls": _last_draw_calls,
		"primitives": _last_primitives,
		"objects": _last_objects,
		"nodes": _last_nodes,
		"texture_memory_mb": _last_texture_memory,
		"video_memory_mb": _last_video_memory,
		"physics_3d_objects": _last_physics_objects,
		"physics_3d_collisions": _last_physics_collisions,
		"fps_drops": _fps_drops,
		"current_scene": _current_scene,
		"peak_primitives": _peak_primitives,
		"peak_draw_calls": _peak_draw_calls,
		"peak_objects": _peak_objects,
		"peak_memory_mb": _peak_memory,
		"log_entries": len(_log_buffer),
		"frame_count": _frame_count
	}

func force_log_flush():
	_flush_log()
	_flush_alerts()

func set_log_interval(seconds: float):
	log_interval = max(0.5, seconds)

func get_log_directory() -> String:
	return ProjectSettings.globalize_path(LOG_FILE_PATH.get_base_dir())

func export_to_json() -> Dictionary:
	return {
		"meta": {
			"game": ProjectSettings.get_setting("application/config/name"),
			"export_time": Time.get_datetime_string_from_system(),
			"godot_version": Engine.get_version_info().string,
			"log_file": LOG_FILE_PATH,
			"alert_log": ALERT_LOG_PATH
		},
		"performance": get_performance_summary(),
		"scenes": _scene_stats
	}

func read_last_log_entries(count: int = 100) -> Array:
	var entries: Array = []
	var file = FileAccess.open(LOG_FILE_PATH, FileAccess.READ)
	if file:
		var lines = file.get_as_text().split("\n")
		var start = max(0, lines.size() - count - 1)
		for i in range(start, lines.size()):
			if lines[i].strip_edges() != "":
				entries.append(lines[i])
		file.close()
	return entries

func read_alerts(count: int = 50) -> Array:
	var entries: Array = []
	var file = FileAccess.open(ALERT_LOG_PATH, FileAccess.READ)
	if file:
		var lines = file.get_as_text().split("\n")
		var start = max(0, lines.size() - count - 1)
		for i in range(start, lines.size()):
			if lines[i].strip_edges() != "":
				entries.append(lines[i])
		file.close()
	return entries

func clear_log():
	_flush_log()
	_log_buffer.clear()
	var file = FileAccess.open(LOG_FILE_PATH, FileAccess.WRITE)
	if file:
		var header = "timestamp,scene,fps,frame_time_ms,render_time_ms,physics_time_ms,draw_calls,primitives,objects,nodes,texture_memory_mb,video_memory_mb,physics_objects,physics_collisions,process_delta\n"
		file.store_string(header)
		file.close()

func clear_alerts():
	_flush_alerts()
	_alert_buffer.clear()
	var file = FileAccess.open(ALERT_LOG_PATH, FileAccess.WRITE)
	if file:
		var header = "timestamp,scene,severity,message,fps,draw_calls,primitives,memory_mb\n"
		file.store_string(header)
		file.close()

# Функция для принудительной установки имени сцены (для случаев с динамическими сценами)
func set_scene_name(name: String):
	_previous_scene = _current_scene
	_current_scene = name
	
	# Инициализируем статистику
	if not _scene_stats.has(_current_scene):
		_scene_stats[_current_scene] = {
			"first_visit": Time.get_unix_time_from_system(),
			"visit_count": 1,
			"total_time": 0.0,
			"avg_fps": 0.0,
			"peak_primitives": 0,
			"peak_draw_calls": 0,
			"peak_objects": 0,
			"fps_drops": 0
		}
	
	_add_alert("INFO", "Сцена установлена вручную: %s" % name)

# Получить отчет по сцене в читаемом формате
func get_scene_report(scene_name: String = "") -> String:
	if scene_name == "":
		scene_name = _current_scene
	
	var stats = _scene_stats.get(scene_name, {})
	if stats.is_empty():
		return "Сцена '%s' не найдена в статистике" % scene_name
	
	var report = "=== ОТЧЕТ ПО СЦЕНЕ: %s ===\n" % scene_name
	report += "Посещений: %d\n" % stats.get("visit_count", 0)
	report += "Время в сцене: %.1f сек\n" % stats.get("total_time", 0.0)
	report += "Средний FPS: %.1f\n" % stats.get("avg_fps", 0.0)
	report += "Пик примитивов: %d\n" % stats.get("peak_primitives", 0)
	report += "Пик draw calls: %d\n" % stats.get("peak_draw_calls", 0)
	report += "Пик объектов: %d\n" % stats.get("peak_objects", 0)
	report += "Падений FPS: %d\n" % stats.get("fps_drops", 0)
	
	return report

# Функция для мониторинга конкретных объектов в сцене
func analyze_scene_objects() -> Dictionary:
	var scene = get_tree().current_scene
	if not scene:
		return {}
	
	var analysis = {
		"total_nodes": 0,
		"mesh_instances": 0,
		"collision_shapes": 0,
		"lights": 0,
		"particles": 0,
		"navigation": 0,
		"audio": 0,
		"scripts": 0
	}
	
	# Рекурсивный обход дерева
	_analyze_node(scene, analysis)
	
	return analysis

func _analyze_node(node: Node, analysis: Dictionary):
	analysis["total_nodes"] += 1
	
	# Проверяем тип узла
	if node is MeshInstance3D:
		analysis["mesh_instances"] += 1
	elif node is CollisionShape3D or node is CollisionPolygon3D:
		analysis["collision_shapes"] += 1
	elif node is Light3D:
		analysis["lights"] += 1
	elif node is GPUParticles3D or node is CPUParticles3D:
		analysis["particles"] += 1
	elif node is NavigationAgent3D or node is NavigationRegion3D:
		analysis["navigation"] += 1
	elif node is AudioStreamPlayer3D:
		analysis["audio"] += 1
	
	# Проверяем наличие скрипта
	if node.get_script():
		analysis["scripts"] += 1
	
	# Рекурсивно обходим детей
	for child in node.get_children():
		_analyze_node(child, analysis)

# Функция для получения рекомендаций по оптимизации
func get_optimization_recommendations() -> Array:
	var recommendations = []
	var scene_analysis = analyze_scene_objects()
	
	# Анализируем результаты
	if scene_analysis.get("mesh_instances", 0) > 100:
		recommendations.append("💡 Используйте GPU Instancing для %d MeshInstance3D узлов" % scene_analysis["mesh_instances"])
	
	if scene_analysis.get("collision_shapes", 0) > 50:
		recommendations.append("💡 Упростите коллайдеры для %d объектов, используйте примитивные формы" % scene_analysis["collision_shapes"])
	
	if scene_analysis.get("lights", 0) > 10:
		recommendations.append("💡 Слишком много источников света (%d). Используйте light culling" % scene_analysis["lights"])
	
	if scene_analysis.get("particles", 0) > 5:
		recommendations.append("💡 Много particle систем (%d). Уменьшите количество частиц или используйте GPU Particles" % scene_analysis["particles"])
	
	if scene_analysis.get("scripts", 0) > 200:
		recommendations.append("💡 Много скриптов (%d). Объедините логику, используйте сигналы" % scene_analysis["scripts"])
	
	if _last_primitives > 300000:
		recommendations.append("💡 Высокая геометрия (%d примитивов). Используйте LOD для дальних объектов" % _last_primitives)
	
	if _last_draw_calls > 500:
		recommendations.append("💡 Много draw calls (%d). Объедините материалы и используйте атласы текстур" % _last_draw_calls)
	
	if _last_texture_memory > 300:
		recommendations.append("💡 Высокое использование памяти текстур (%.1f MB). Оптимизируйте размеры текстур" % _last_texture_memory)
	
	if _last_nodes > 3000:
		recommendations.append("💡 Много узлов (%d). Удалите невидимые объекты, используйте пулы" % _last_nodes)
	
	if _last_physics_objects > 20:
		recommendations.append("💡 Много физических объектов (%d). Оптимизируйте физику, используйте слои" % _last_physics_objects)
	
	return recommendations
