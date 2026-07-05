extends CharacterBody3D

@onready var shock_sound: AudioStreamPlayer3D = $shock
@onready var spark_dead: GPUParticles3D = $sparkDead if has_node("sparkDead") else null
@onready var spark_hit: GPUParticles3D = $spark if has_node("spark") else null

@export var is_boss: bool = false
@export var aura: int = 0

var double_damage_in_air: bool = true
var should_shatter: bool = false
var shatter_parts: Array[Node3D] = []

var is_dead: bool = false
var is_dying: bool = false
var death_timer: float = 0.0
const DEATH_DELAY: float = 1.0

var health: int = 1
var player: Node3D = null
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var speed_multiplier: float = 1.0 

func _ready():
	player = get_tree().get_first_node_in_group("player")
	if aura > 0:
		speed_multiplier = aura + 1
		_apply_aura()

func _setup_boss_bar():
	if is_boss:
		var boss_bars = get_tree().get_nodes_in_group("BossBar")
		if boss_bars.size() > 0:
			boss_bars[0].setup_boss(health, _get_boss_id())

func _apply_aura():
	if has_node("Aura/AnimationPlayer"):
		$Aura/AnimationPlayer.play("aura")
	var aura_color = Color("#ff7a01") if aura == 1 else Color("#f50000")
	if has_node("Aura"):
		$Aura.modulate = aura_color

func take_damage(damage: int):
	if is_dying or is_dead:
		return
	health -= damage
	if double_damage_in_air and not is_on_floor():
		health -= damage
	if spark_hit:
		spark_hit.emitting = true
	if is_boss:
		var boss_bars = get_tree().get_nodes_in_group("BossBar")
		if boss_bars.size() > 0:
			boss_bars[0]._on_health_changed(health)
	if health <= 0:
		if spark_dead:
			spark_dead.emitting = true
		die()

func die():
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
	if should_shatter:
		await get_tree().create_timer(1.0).timeout
		if not is_dead and is_dying:
			_shatter_into_parts()
			visible = false
			await get_tree().create_timer(3.0).timeout
			if self and is_instance_valid(self):
				queue_free()
	else:
		death_timer = 0.0

func _shatter_into_parts():
	if shatter_parts.is_empty():
		return
	for part in shatter_parts:
		if not part:
			continue
		create_physical_copy(part, Vector3(0.8, 0.8, 0.8), Vector3.ZERO)

func create_physical_copy(original_node: Node3D, collision_size: Vector3, _local_offset: Vector3):
	if not original_node:
		return
	var rigid = RigidBody3D.new()
	rigid.name = "shatter_" + original_node.name
	rigid.global_transform = original_node.global_transform
	rigid.mass = 8.0
	rigid.gravity_scale = 1.0
	rigid.linear_damp = 0.3
	rigid.angular_damp = 0.3
	rigid.collision_layer = 0 
	rigid.collision_layer |= (1 << 1)
	rigid.collision_mask = 0
	rigid.collision_mask |= (1 << 2)
	var collision = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = collision_size
	collision.shape = box_shape
	rigid.add_child(collision)
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
	await get_tree().create_timer(3.0).timeout
	if rigid and is_instance_valid(rigid):
		rigid.queue_free()

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
	if should_shatter:
		death_timer += delta
		if death_timer >= DEATH_DELAY:
			is_dead = true
		return
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
		queue_free()
