extends CharacterBody3D

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var health_label: Label3D = $hp

@export var is_boss = false
@export var aura = 0

var is_dying: bool = false
var death_timer: float = 0.0
var DEATH_DELAY: float = 1

var current_target: Node3D = null
var player: Node3D = null
var is_chasing_player: bool = false

# Настройки движения
var SPEED: float = 6
var ACCELERATION: float = 5.0
var ROTATION_SPEED: float = 10.0
var last_animation_state: String = ""

# Дистанция атаки
var ATTACK_DISTANCE: float = 2.0 
var KNOCKBACK_FORCE: float = 50.0  # Сила отталкивания
var is_attacking: bool = false

var previous_position: Vector3
var movement_direction: Vector3
var spawnpoint: Vector3

var is_dead: bool = false
var health: int = 80

var attack_cooldown: float = 0.0
var ATTACK_COOLDOWN_TIME: float = 1.5

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

#стрельба
var SHOOT_DISTANCE_MIN: float = 3.0  # минимальная дистанция для стрельбы
var SHOOT_DISTANCE_MAX: float = 12.0 # максимальная дистанция для стрельбы
var shoot_timer: float = 0.0
var SHOOT_COOLDOWN: float = 3.5
var is_shooting_mode: bool = false
var bullet_scene = preload("res://chapter2/item/Enemy_projectile/Enemy_projectile.tscn")

func _ready():
	if !Global.game_settings["Enemy"]:
		queue_free()
		return
	if !Global.game_settings["GhostMod"]:
		player = get_tree().get_first_node_in_group("player")
	previous_position = global_position
	current_target = null
	if aura > 0:
		auraSprite()
	update_health_label()
	var boss_bars = get_tree().get_nodes_in_group("BossBar")
	if boss_bars.size() > 0 and is_boss:
		health = 420
		$body/body/Sprite3D.visible = true
		boss_bars[0].setup_boss(health, "infantryman")
	if player:
		start_chasing_player()
		shoot_timer = 2.0

func auraSprite():
	$Aura/AnimationPlayer.play("aura")
	if aura == 1:
		$Aura.modulate = Color("#ff7a01")
	else:
		$Aura.modulate = Color("#f50000")
	SPEED *= aura + 1
	health *= aura + 1
	SHOOT_COOLDOWN /= aura + 1

func _physics_process(delta):
	if is_dead:
		return
	if is_dying:
		death_timer += delta
		if death_timer < 1.0:
			var shake_intensity = 0.05 * (1.0 - death_timer / DEATH_DELAY)
			var shake_offset = Vector3(
				randf_range(-shake_intensity, shake_intensity),
				randf_range(-shake_intensity, shake_intensity),
				randf_range(-shake_intensity, shake_intensity)
			)
			global_position += shake_offset
			velocity = velocity.lerp(Vector3.ZERO, ACCELERATION * delta)
			move_and_slide()
		return
	if not is_on_floor():
		velocity.y -= gravity * delta
	if attack_cooldown > 0:
		attack_cooldown -= delta
	if not is_chasing_player:
		velocity = velocity.lerp(Vector3.ZERO, ACCELERATION * delta)
		move_and_slide()
		return
	if player:
		if is_attacking:
			move_and_slide()
			return
		var distance_to_player = global_position.distance_to(player.global_position)
		if distance_to_player >= SHOOT_DISTANCE_MIN and distance_to_player <= SHOOT_DISTANCE_MAX:
			is_shooting_mode = true
			if last_animation_state != "shoot_mode":
				$body/run.play_backwards("run")
				$body/AnimationPlayer.play("weapon")
				last_animation_state = "shoot_mode"
			var direction_to_player = (player.global_position - global_position).normalized()
			if direction_to_player.length() > 0.1:
				var target_rotation = atan2(direction_to_player.x, direction_to_player.z)
				rotation.y = lerp_angle(rotation.y, target_rotation, ROTATION_SPEED * delta)
			if shoot_timer <= 0:
				shoot_at_player()
				shoot_timer = SHOOT_COOLDOWN
			else:
				shoot_timer -= delta
			velocity = velocity.lerp(Vector3.ZERO, ACCELERATION * delta)
			move_and_slide()
			return
		is_shooting_mode = false
		if last_animation_state != "move_mode":
			$body/run.play("run")
			$body/AnimationPlayer.play("RESET")
			last_animation_state = "move_mode"
		navigation_agent.target_position = player.global_position
		if can_attack_player():
			attack_player()
		var next_position = navigation_agent.get_next_path_position()
		var direction = (next_position - global_position).normalized()
		if direction.length() > 0.1:
			var target_rotation = atan2(direction.x, direction.z)
			rotation.y = lerp_angle(rotation.y, target_rotation, ROTATION_SPEED * delta)
		var target_velocity = direction * SPEED
		target_velocity.y = velocity.y
		velocity = velocity.lerp(target_velocity, ACCELERATION * delta)
	movement_direction = global_position - previous_position
	previous_position = global_position
	move_and_slide()

func can_attack_player() -> bool:
	if not player:
		return false
	var distance_to_player = global_position.distance_to(player.global_position)
	return distance_to_player <= ATTACK_DISTANCE

func lose_player():
	is_chasing_player = false

func start_chasing_player():
	current_target = player
	is_chasing_player = true

func stop_chasing_player():
	is_chasing_player = false
	current_target = null

func attack_player():
	if not can_attack_player() or is_dead:
		return
	if attack_cooldown <= 0 and not is_attacking:
		if player:
			is_attacking = true
			$hit.pitch_scale = randf_range(4, 6)
			$body/AnimationPlayer.play("attack")
			if player.has_method("HP"):
				player.HP(20)
			if player.has_method("take_damage"):
				player.take_damage(20)
			if player is CharacterBody3D:
				var knockback_direction = (player.global_position - global_position).normalized()
				player.velocity.x = knockback_direction.x * KNOCKBACK_FORCE
				player.velocity.z = knockback_direction.z * KNOCKBACK_FORCE
				player.velocity.y = KNOCKBACK_FORCE * 0.1
			attack_cooldown = ATTACK_COOLDOWN_TIME
			await get_tree().create_timer(0.5).timeout
			is_attacking = false

func shoot_at_player():
	if not player:
		return
	var bullet_spawn = $body/hand1/BulletSpawn
	if not bullet_spawn:
		return
	var bullet = bullet_scene.instantiate()
	get_tree().root.add_child(bullet)
	bullet.global_position = bullet_spawn.global_position
	var target_pos = player.global_position
	target_pos.y = bullet_spawn.global_position.y
	var shoot_direction = (target_pos - bullet_spawn.global_position).normalized()
	bullet.shoot(shoot_direction, 10.0)
	var audio = $body/hand1/Taser/AudioStreamPlayer3D
	if audio:
		audio.play()

func die():
	if is_dying or is_dead:
		return
	is_dying = true
	death_timer = 0.0
	$sparkDead.emitting = true
	$shock.pitch_scale = randf_range(0.9, 1.1)
	$shock.play()
	velocity = Vector3.ZERO
	is_chasing_player = false
	await get_tree().create_timer(1.0).timeout
	if not is_dead and is_dying:
		create_physical_copy($body/body, Vector3(1.2, 1.5, 0.8), Vector3(0, 1, 0)) 
		create_physical_copy($body/hand1, Vector3(0.6, 0.3, 0.3), Vector3(0.5, 0.8, 0.3)) 
		create_physical_copy($body/hand2, Vector3(0.6, 0.3, 0.3), Vector3(-0.5, 0.8, 0.3))
		visible = false
		await get_tree().create_timer(3.0).timeout
		if self and is_instance_valid(self):
			queue_free()

func take_damage(damage):
	health -= damage
	if not is_on_floor():
		health -= damage
	update_health_label()
	var boss_bars = get_tree().get_nodes_in_group("BossBar")
	if boss_bars.size() > 0 and is_boss:
		boss_bars[0]._on_health_changed(health)
	if health <= 0:
		$sparkDead.emitting = true
		die()
	else:
		$spark.emitting = true

func update_health_label():
	if health_label:
		health_label.text = str(health) + " HP"
		if health <= 5:
			health_label.modulate = Color(1, 0.3, 0.3) 
		elif health <= 10:
			health_label.modulate = Color(1, 0.8, 0.3)
		else:
			health_label.modulate = Color(1, 1, 1)

func create_physical_copy(original_node: Node3D, collision_size: Vector3, _local_offset: Vector3):
	if not original_node:
		return
	var rigid = RigidBody3D.new()
	rigid.name = "ragdoll_" + original_node.name
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
