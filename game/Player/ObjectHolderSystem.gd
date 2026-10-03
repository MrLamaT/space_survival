extends Node
class_name ObjectHolderSystem

# ==================== ССЫЛКИ ====================
var player: CharacterBody3D        # Ссылка на игрока
var cam: Camera3D                  # Камера игрока
var head: Node3D                   # Голова игрока (для поворота)

# ==================== СОСТОЯНИЕ ====================
var held_object: Node = null       # Удерживаемый объект
var hold_distance: float = 2.0     # Дистанция удержания
var min_safe_distance: float = 2.0 # Минимальная безопасная дистанция

# ==================== НАСТРОЙКИ ====================
@export var throw_strength: float = 15.0    # Сила броска
@export var throw_up_force: float = 2.0     # Подброс вверх при броске
@export var throw_spin_range: float = 2.0   # Случайное вращение при броске

# ==================== СИГНАЛЫ ====================
signal object_picked_up(object: Node)
signal object_released(object: Node, thrown: bool)

# Инициализация системы
func setup(player_ref: CharacterBody3D, cam_ref: Camera3D, head_ref: Node3D) -> void:
	player = player_ref
	cam = cam_ref
	head = head_ref

# Проверяет, удерживается ли какой-либо объект
func is_holding() -> bool:
	return held_object != null and is_instance_valid(held_object)

# Начинает перемещение объекта (подбор)
func pick_up(build: Node) -> bool:
	if not is_instance_valid(build):
		return false
	if held_object == build:
		return false
	if is_holding():
		release(false)
	held_object = build
	var distance_to_build = player.global_position.distance_to(build.global_position)
	if distance_to_build < min_safe_distance:
		var direction_to_build = build.global_position - player.global_position
		direction_to_build.y = 0
		direction_to_build = direction_to_build.normalized()
		if direction_to_build.length() < 0.1:
			var forward = -cam.global_transform.basis.z
			forward.y = 0
			direction_to_build = forward.normalized()
		build.global_position = player.global_position + (direction_to_build * min_safe_distance)
		hold_distance = min_safe_distance
	else:
		hold_distance = distance_to_build
	object_picked_up.emit(build)
	return true

# Обновляет позицию удерживаемого объекта
func update_held_object() -> void:
	if not is_holding():
		return
	var camera_forward = -cam.global_transform.basis.z
	camera_forward = camera_forward.normalized()
	var target_position = cam.global_position + (camera_forward * hold_distance)
	held_object.global_position = target_position
	if held_object is RigidBody3D:
		held_object.linear_velocity = Vector3.ZERO
		held_object.angular_velocity = Vector3.ZERO
	var target_rotation = head.global_rotation
	target_rotation.x = 0
	target_rotation.z = 0
	held_object.global_rotation = target_rotation

# Отпускает удерживаемый объект
# throw_force = true — объект бросается вперёд
func release(throw_force: bool = false) -> void:
	if not is_holding():
		held_object = null
		return

	var obj = held_object
	held_object = null

	if throw_force and obj is RigidBody3D:
		var throw_dir = -cam.global_transform.basis.z
		obj.linear_velocity = throw_dir * throw_strength + Vector3.UP * throw_up_force
		obj.angular_velocity = Vector3(
			randf_range(-throw_spin_range, throw_spin_range),
			randf_range(-throw_spin_range, throw_spin_range),
			randf_range(-throw_spin_range, throw_spin_range)
		)

	object_released.emit(obj, throw_force)
