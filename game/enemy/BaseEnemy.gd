extends CharacterBody3D

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var shock_sound: AudioStreamPlayer3D = $shock
@onready var spark_dead: GPUParticles3D
@onready var spark_hit: GPUParticles3D

@export var is_boss: bool = false
@export var aura: int = 0
@export var enemyTags: String = "player"
@export var health: int = 1
@export var boss_health: int = 1
@export var SPEED: float = 1
@export var ACCELERATION: float = 1
@export var ROTATION_SPEED: float = 10.0
@export var watch = false

const SPARK_SCENE = preload("res://game/enemy/SparkEnemy.tscn")
const SPARK_DEAD_SCENE = preload("res://game/enemy/SparkDeadEnemy.tscn")
const PORTAL_SCENE = preload("res://game/wave/WavePortal.tscn")

var double_damage_in_air: bool = true
var shatter_parts: Array[Node3D] = []

var max_health: int = 1
var is_dead: bool = false
var is_dying: bool = false
var death_timer: float = 0.0
const DEATH_DELAY: float = 1.0

var player: Node3D = null
var _search_cooldown: float = 0.0
const SEARCH_DELAY: float = 0.5
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var speed_multiplier: float = 1.0 

var boss_bars: CanvasLayer = null

var shatter_scene = preload("res://game/enemy/shatter.tscn")

func _ready():
	var spark_instance = SPARK_SCENE.instantiate()
	add_child(spark_instance)
	spark_hit = spark_instance
	var spark_dead_instance = SPARK_DEAD_SCENE.instantiate()
	add_child(spark_dead_instance)
	spark_dead = spark_dead_instance
	player = get_tree().get_first_node_in_group(enemyTags)
	if aura > 0:
		speed_multiplier = aura + 1
		_apply_aura()
	if is_boss and boss_health > health:
		health = boss_health
	health *= int(speed_multiplier)
	max_health = health
	SPEED *= speed_multiplier
	ROTATION_SPEED *= speed_multiplier
	_setup_boss_bar()

func _physics_process(delta):
	if Global.game_settings["UI"] or Global.game_settings["GhostMod"]:
		return
	if is_dead:
		return
	if abs(global_position.y) > 1000.0:
		print("KillZona - ", name, " (удалён)")
		queue_free()
		return
	if is_dying:
		_handle_death_process(delta)
		return
	if not player:
		_search_cooldown -= delta
		if _search_cooldown <= 0:
			player = get_tree().get_first_node_in_group(enemyTags)
			_search_cooldown = SEARCH_DELAY
	if watch:
		_process_enemy_watch(delta)
		return
	_process_enemy_behavior(delta)

func _process_enemy_watch(_delta):
	pass

func _process_enemy_behavior(_delta):
	pass

func _setup_boss_bar():
	if is_boss:
		var boss_bars_scene = load("res://UI/BossBar/BossBar.tscn")
		var boss_bars_instance = boss_bars_scene.instantiate()
		add_child(boss_bars_instance)
		boss_bars_instance.setup_boss(health, _get_boss_id())
		boss_bars = boss_bars_instance

func ResetHealth():
	health = max_health

func _apply_aura():
	if has_node("Aura/AnimationPlayer"):
		$Aura/AnimationPlayer.play("aura")
	var aura_color = Color("#ff7a01") if aura == 1 else Color("#f50000")
	if has_node("Aura"):
		$Aura.modulate = aura_color

func take_damage(damage: int): #получение урона
	if is_dying or is_dead:
		return
	health -= damage
	if double_damage_in_air and not is_on_floor():
		health -= damage
	if spark_hit:
		spark_hit.emitting = true
	if is_boss:
		boss_bars._on_health_changed(health)
	if health <= 0:
		if spark_dead:
			spark_dead.emitting = true
		die()

func die(): #смерть
	if is_dying or is_dead:
		return
	is_dying = true
	if shock_sound:
		shock_sound.pitch_scale = randf_range(0.9, 1.1)
		shock_sound.play()
	velocity = Vector3.ZERO
	if has_node("body/AnimationPlayer"):
		$body/AnimationPlayer.stop()
		$body/AnimationPlayer.play("RESET")
	_disable_combat_states()
	death_timer = 0.0

func _shatter_into_parts(): #физ смерть
	if shatter_parts.is_empty():
		return
	for part in shatter_parts:
		if not part:
			continue
		create_physical_copy(part, Vector3(0.8, 0.8, 0.8), Vector3.ZERO)

func create_physical_copy(original_node: Node3D, collision_size: Vector3, _local_offset: Vector3):
	if not original_node:
		return
	var rigid = shatter_scene.instantiate()
	rigid.global_transform = original_node.global_transform
	var collision = rigid.get_node("CollisionShape3D")
	var box_shape = BoxShape3D.new()
	box_shape.size = collision_size
	collision.shape = box_shape
	for child in original_node.get_children():
		if child is MeshInstance3D or child is Sprite3D or child is GPUParticles3D:
			var copy = _duplicate_node_recursive(child)
			rigid.add_child(copy)
	get_parent().add_child(rigid)
	var impulse = Vector3(
		randf_range(-8, 8),
		randf_range(5, 12),
		randf_range(-8, 8)
	)
	rigid.apply_central_impulse(impulse)
	rigid.angular_velocity = Vector3(
		randf_range(-5, 5),
		randf_range(-5, 5),
		randf_range(-5, 5)
	)

func _duplicate_node_recursive(node: Node) -> Node:
	var copy = node.duplicate(Node.DUPLICATE_USE_INSTANTIATION | Node.DUPLICATE_SIGNALS)
	if copy is MeshInstance3D and node is MeshInstance3D:
		if node.mesh:
			copy.mesh = node.mesh.duplicate()
		if node.material_override:
			copy.material_override = node.material_override.duplicate()
	if copy is GPUParticles3D:
		copy.emitting = true
	for child in node.get_children():
		var child_copy = _duplicate_node_recursive(child)
		copy.add_child(child_copy)
	return copy

func _disable_combat_states(): 
	pass

func _get_boss_id() -> String:
	return "enemy"

func _handle_death_process(delta):
	death_timer += delta
	var shake_intensity = 0.05 * (1.0 - death_timer / DEATH_DELAY)
	var shake_offset = Vector3(
		randf_range(-shake_intensity, shake_intensity),
		randf_range(-shake_intensity, shake_intensity),
		randf_range(-shake_intensity, shake_intensity)
	)
	global_position += shake_offset
	velocity = velocity.lerp(Vector3.ZERO, 5.0 * delta)
	move_and_slide()
	if death_timer >= DEATH_DELAY:
		is_dead = true
		if not shatter_parts.is_empty():
			_shatter_into_parts()
		queue_free()

## Основной метод перемещения с использованием навигации
## target_pos — конечная цель (обычно позиция игрока)
## delta — дельта времени
## speed — переопределение скорости (по умолчанию SPEED)
## rot_speed — переопределение скорости поворота (по умолчанию ROTATION_SPEED)
func move_with_navigation(target_pos: Vector3, delta: float, speed: float = SPEED, rot_speed: float = ROTATION_SPEED) -> void:
	if not navigation_agent:
		return
	navigation_agent.target_position = target_pos
	var direction = (navigation_agent.get_next_path_position() - global_position).normalized()
	if direction.length() > 0.1:
		var target_rotation = atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_rotation, rot_speed * delta)
	var target_velocity = direction * speed
	target_velocity.y = velocity.y
	velocity = velocity.lerp(target_velocity, ACCELERATION * delta)

## Создает и запускает пулю из указанной позиции в направлении цели
## spawn_position: Vector3 - позиция появления пули
## target_position: Vector3 - целевая позиция (обычно позиция игрока)
## bullet_scene: PackedScene - сцена пули
## speed: float - скорость пули (по умолчанию 10.0)
## y_offset: float - вертикальное смещение для выравнивания (по умолчанию 0.0)
func create_bullet(spawn_position: Vector3, target_position: Vector3, bullet_scene: PackedScene, speed: float = 10.0, y_offset: float = 0.0) -> Node:
	if not bullet_scene:
		return null
	var bullet = bullet_scene.instantiate()
	get_tree().root.add_child(bullet)
	bullet.global_position = spawn_position
	var target_pos = target_position
	if y_offset != 0:
		target_pos.y = spawn_position.y + y_offset
	else:
		target_pos.y = spawn_position.y
	var shoot_direction = (target_pos - spawn_position).normalized()
	if bullet.has_method("shoot"):
		bullet.shoot(shoot_direction, speed)
	return bullet
