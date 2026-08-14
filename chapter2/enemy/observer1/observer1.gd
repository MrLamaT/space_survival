extends "res://chapter2/enemy/BaseEnemy.gd"
@export var watch = false

# Стрельба
var bullet_scene = preload("res://chapter2/item/Homing_projectile/Homing_projectile.tscn")
var can_shoot: bool = true
var BURST_SHOTS: int = 3
var BURST_INTERVAL: float = 0.4
var BURST_COOLDOWN_TIME: float = 2.0

# Прыжок
var is_jumping: bool = false
var jump_target_position: Vector3
var jump_timeout: float = 0.0
var JUMP_MAX_TIME: float = 2.0
var JUMP_LAUNCH_SPEED: float = 5.0
var JUMP_SPEED: float = 12.0

# Телепорт
var is_teleporting: bool = false
var DISTANCE_IDEAL = 5.0  # Идеальная дистанция
var DISTANCE_MIN = 3.0    # Минимальная дистанция (слишком близко)
var DISTANCE_MAX = 12.0   # Максимальная дистанция (слишком далеко)
var portal_scene = preload("res://chapter2/wave/WavePortal.tscn")

# Система атак
enum AttackType { SHOOT, JUMP, TELEPORT }

var can_act: bool = true  # Может ли враг выполнять действия
var spawn_protection: float = 1.5  # Защита после появления

var attack_queue: Array = [AttackType.SHOOT, AttackType.JUMP, AttackType.TELEPORT]  # Очередь атак
var current_attack_index: int = 0
var is_attacking: bool = false

func _ready():
	super._ready()
	BURST_COOLDOWN_TIME /= speed_multiplier
	can_act = false
	await get_tree().create_timer(spawn_protection).timeout
	can_act = true

func _disable_combat_states():
	is_jumping = false
	is_teleporting = false

func _get_boss_id() -> String:
	return "phantom observer"

func _process_enemy_behavior(delta):
	if watch:
		if player and global_position.distance_to(player.global_position) < 10.0:
			create_portal(global_position)
			queue_free()
		move_and_slide()
		return
	if is_jumping:
		handle_jump(delta)
		return
	if is_teleporting:
		move_and_slide()
		return
	# Физика
	if not is_on_floor():
		velocity.y -= gravity * delta
	if not player:
		move_and_slide()
		return
	var direction_to_player = (player.global_position - global_position).normalized()
	if direction_to_player.length() > 0.1:
		var target_rotation = atan2(direction_to_player.x, direction_to_player.z)
		rotation.y = lerp_angle(rotation.y, target_rotation, ROTATION_SPEED * delta)
	if can_act and not is_jumping and not is_teleporting and not is_attacking:
		perform_next_attack()
	velocity = velocity.lerp(Vector3.ZERO, 5.0 * delta)
	move_and_slide()

func perform_next_attack():
	if is_attacking:
		return
	var attack_type = attack_queue[current_attack_index]
	current_attack_index = (current_attack_index + 1) % attack_queue.size()
	start_attack_by_type(attack_type)

func start_attack_by_type(attack_type: AttackType):
	is_attacking = true
	match attack_type:
		AttackType.SHOOT:
			start_shoot_attack()
		AttackType.JUMP:
			start_jump_attack()
		AttackType.TELEPORT:
			start_teleport_attack()

func start_shoot_attack():
	if not can_act or is_jumping or is_teleporting:
		is_attacking = false
		return
	print("стрельба!")
	can_act = false
	$body/AnimationPlayer.play("weapon")
	await shoot_burst()
	can_act = true
	is_attacking = false

func shoot_burst():
	for i in range(BURST_SHOTS):
		if not is_instance_valid(self) or is_dead:
			is_attacking = false
			return
		shoot_at_player()
		if i < BURST_SHOTS - 1:
			await get_tree().create_timer(BURST_INTERVAL).timeout
	await get_tree().create_timer(0.2).timeout

func start_jump_attack():
	if not can_act or is_jumping or is_teleporting:
		is_attacking = false
		return
	print("прыжок!")
	can_act = false
	$body/AnimationPlayer.play("jump")
	await get_tree().create_timer(0.2).timeout 
	start_jump_to_player()
	while is_jumping and is_instance_valid(self) and not is_dead:
		await get_tree().process_frame
	can_act = true
	is_attacking = false

func start_teleport_attack():
	if not can_act or is_jumping or is_teleporting:
		is_attacking = false
		return
	print("телепорт!")
	can_act = false
	teleport_near_player()
	while is_teleporting and is_instance_valid(self) and not is_dead:
		await get_tree().process_frame
	can_act = true
	is_attacking = false

func emergency_teleport():
	if not player or is_teleporting:
		return
	print("экстренный телепорт!")
	is_teleporting = true
	is_jumping = false
	create_portal(global_position)
	var random_angle = randf_range(0, TAU)
	var offset = Vector3(cos(random_angle), 0, sin(random_angle)) * DISTANCE_IDEAL
	var teleport_pos = player.global_position + offset
	teleport_pos.y = global_position.y
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(global_position, teleport_pos)
	var result = space_state.intersect_ray(query)
	if not result.is_empty():
		random_angle = randf_range(0, TAU)
		offset = Vector3(cos(random_angle), 0, sin(random_angle)) * DISTANCE_IDEAL
		teleport_pos = player.global_position + offset
		teleport_pos.y = global_position.y
	global_position = teleport_pos
	create_portal(global_position)
	$body/AnimationPlayer.play("RESET")
	await get_tree().create_timer(0.2).timeout
	is_teleporting = false

func create_portal(pos: Vector3):
	var portal = portal_scene.instantiate()
	get_tree().root.add_child(portal)
	portal.global_position = pos

func teleport_near_player():
	if not player or is_teleporting:
		return
	is_teleporting = true
	is_jumping = false
	create_portal(global_position)
	var random_angle = randf_range(0, TAU)
	var random_distance = randf_range(2.5, 4.0)  
	var offset = Vector3(cos(random_angle), 0, sin(random_angle)) * random_distance
	var teleport_pos = player.global_position + offset
	teleport_pos.y = global_position.y
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(global_position, teleport_pos)
	var result = space_state.intersect_ray(query)
	if not result.is_empty():
		random_angle = randf_range(0, TAU)
		random_distance = randf_range(4.0, 6.0)
		offset = Vector3(cos(random_angle), 0, sin(random_angle)) * random_distance
		teleport_pos = player.global_position + offset
		teleport_pos.y = global_position.y
	global_position = teleport_pos
	create_portal(global_position)
	$body/AnimationPlayer.play("RESET")
	await get_tree().create_timer(0.3).timeout
	is_teleporting = false

func shoot_at_player():
	if not player:
		return
	var bullet_spawn1 = $body/BulletSpawn
	if bullet_spawn1:
		var bullet1 = bullet_scene.instantiate()
		get_tree().root.add_child(bullet1)
		bullet1.global_position = bullet_spawn1.global_position
		var target_pos1 = player.global_position
		target_pos1.y = bullet_spawn1.global_position.y
		var shoot_direction1 = (target_pos1 - bullet_spawn1.global_position).normalized()
		bullet1.shoot(shoot_direction1, 5.0)
	var bullet_spawn2 = $body/BulletSpawn2
	if bullet_spawn2:
		var bullet2 = bullet_scene.instantiate()
		get_tree().root.add_child(bullet2)
		bullet2.global_position = bullet_spawn2.global_position
		var target_pos2 = player.global_position
		target_pos2.y = bullet_spawn2.global_position.y
		var shoot_direction2 = (target_pos2 - bullet_spawn2.global_position).normalized()
		bullet2.shoot(shoot_direction2, 5.0)
	var audio = $body/AudioStreamPlayer3D
	if audio:
		audio.play()

func start_jump_to_player():
	if not player:
		return
	is_jumping = true
	jump_target_position = player.global_position
	jump_timeout = 0.0
	velocity.y = JUMP_LAUNCH_SPEED

func land_from_jump():
	velocity.x = 0
	velocity.z = 0
	is_jumping = false

func handle_jump(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	jump_timeout += delta
	if jump_timeout >= JUMP_MAX_TIME:
		land_from_jump()
		return
	var horizontal_direction = (jump_target_position - global_position).normalized()
	horizontal_direction.y = 0
	if horizontal_direction.length() > 0.1:
		horizontal_direction = horizontal_direction.normalized()
		var target_rotation = atan2(horizontal_direction.x, horizontal_direction.z)
		rotation.y = lerp_angle(rotation.y, target_rotation, ROTATION_SPEED * delta * 2)
		velocity.x = horizontal_direction.x * JUMP_SPEED
		velocity.z = horizontal_direction.z * JUMP_SPEED
	var distance_to_target = global_position.distance_to(jump_target_position)
	var height_difference = abs(global_position.y - jump_target_position.y)
	if distance_to_target < 1.5 and (is_on_floor() or height_difference < 1.0):
		land_from_jump()
	move_and_slide()

func die():
	if is_dying or is_dead:
		return
	super.die()
	is_jumping = false
	is_teleporting = false
