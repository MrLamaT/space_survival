extends "res://game/enemy/BaseEnemy.gd"

# Стрельба
var bullet_scene = preload("res://game/item/Homing_projectile/Homing_projectile.tscn")
var BURST_SHOTS: int = 3
var BURST_INTERVAL: float = 0.4

#луч
@onready var beam_spawns: Array = [
	$BeamSpawn1,
	$BeamSpawn2,
	$BeamSpawn3,
	$BeamSpawn4
]
var beam_charge_duration: float = 2.0
var beam_shoot_duration: float = 1.5
var is_shooting_beam: bool = false

# Подъём в воздух
var is_ascending: bool = false
var ascend_timer: float = 0.0
var ASCEND_DURATION: float = 5.0  # 15 секунд в воздухе
var ASCEND_SPEED: float = 3.0      # Скорость подъёма
var ASCEND_HEIGHT: float = 2.5     # Высота подъёма от текущей позиции
var start_y: float = 0.0           # Начальная высота перед подъёмом
var target_y: float = 0.0          # Целевая высота

# Телепорт
var is_teleporting: bool = false
var spawn_position: Vector3 = Vector3.ZERO

# Система атак
enum AttackType { SHOOT, BEAM , ASCEND, TELEPORT }

var can_act: bool = true  # Может ли враг выполнять действия
var spawn_protection: float = 1.5  # Защита после появления

const attack_queue: Array = [AttackType.SHOOT, AttackType.BEAM, AttackType.ASCEND, AttackType.TELEPORT]  # Очередь атак
var current_attack_index: int = 0
var is_attacking: bool = false

func _ready():
	super._ready()
	spawn_position = global_position
	can_act = false
	await get_tree().create_timer(spawn_protection).timeout
	can_act = true

func _disable_combat_states():
	is_ascending = false
	is_teleporting = false
	is_shooting_beam = false

func _get_boss_id() -> String:
	return "phantom observer"

func _process_enemy_watch(_delta):
	if player and global_position.distance_to(player.global_position) < 10.0:
		create_portal(global_position)
		queue_free()
	move_and_slide()

func _process_enemy_behavior(delta):
	if is_ascending:
		handle_ascend(delta)
		return
	if is_teleporting:
		move_and_slide()
		return
	if is_shooting_beam:
		velocity = velocity.lerp(Vector3.ZERO, 5.0 * delta)
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
	if can_act and not is_ascending and not is_teleporting and not is_attacking:
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
		AttackType.ASCEND:
			start_ascend_attack()
		AttackType.TELEPORT:
			start_teleport_attack()
		AttackType.BEAM:
			start_beam_attack()

func start_shoot_attack():
	if not can_act or is_ascending or is_teleporting:
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

func start_beam_attack():
	if not can_act or is_ascending or is_teleporting:
		is_attacking = false
		return
	print("луч!")
	can_act = false
	$body/AnimationPlayer.play("charge")
	if player:
		var player_pos = player.global_position
		var distance = 5.0
		var spawn_positions = [
			player_pos + Vector3(0, 10.0, distance), 
			player_pos + Vector3(distance, 10.0, 0), 
			player_pos + Vector3(0, 10.0, -distance), 
			player_pos + Vector3(-distance, 10.0, 0) 
		]
		for i in range(beam_spawns.size()):
			if i < spawn_positions.size() and beam_spawns[i]:
				beam_spawns[i].global_position = spawn_positions[i]
	for spawn in beam_spawns:
		spawn.start_charge()
	await get_tree().create_timer(beam_charge_duration).timeout
	if is_dead or not is_instance_valid(self):
		is_attacking = false
		can_act = true
		return
	is_shooting_beam = true
	$body/AnimationPlayer.play("charge_shoot")
	for spawn in beam_spawns:
		spawn.shoot()
	await get_tree().create_timer(beam_shoot_duration).timeout
	is_shooting_beam = false
	for spawn in beam_spawns:
		spawn.reset()
	$body/AnimationPlayer.play("RESET")
	can_act = true
	is_attacking = false

func start_ascend_attack():
	if not can_act or is_ascending or is_teleporting:
		is_attacking = false
		return
	print("лазеры!")
	can_act = false
	$body/AnimationPlayer.play("jump")
	await get_tree().create_timer(0.3).timeout
	$laser/AnimationPlayer.play("laser")
	is_ascending = true
	ascend_timer = 0.0
	start_y = global_position.y
	target_y = start_y + ASCEND_HEIGHT
	while is_ascending and is_instance_valid(self) and not is_dead:
		await get_tree().process_frame
	$laser/AnimationPlayer.play("RESET")
	$body/AnimationPlayer.play("RESET")
	can_act = true
	is_attacking = false

func start_teleport_attack():
	if not can_act or is_ascending or is_teleporting:
		is_attacking = false
		return
	print("телепорт!")
	can_act = false
	teleport_to_spawn()
	while is_teleporting and is_instance_valid(self) and not is_dead:
		await get_tree().process_frame
	can_act = true
	is_attacking = false

func create_portal(pos: Vector3):
	var portal = PORTAL_SCENE.instantiate()
	get_tree().root.add_child(portal)
	portal.global_position = pos

func teleport_to_spawn():
	if is_teleporting:
		return
	is_teleporting = true
	is_ascending = false
	create_portal(global_position)
	var offset_values = [-2.5, 0, 2.5]
	var random_x = offset_values[randi() % offset_values.size()]
	var random_z = offset_values[randi() % offset_values.size()]
	var teleport_pos = spawn_position + Vector3(random_x, 1.0, random_z)
	global_position = teleport_pos
	create_portal(global_position)
	$body/AnimationPlayer.play("RESET")
	await get_tree().create_timer(0.3).timeout
	is_teleporting = false

func shoot_at_player():
	if not player:
		return
	var spawns = [$body/BulletSpawn, $body/BulletSpawn2]
	for spawn in spawns:
		if spawn:
			create_bullet(spawn.global_position, player.global_position, bullet_scene, 5.0)
	var audio = $body/AudioStreamPlayer3D
	if audio:
		audio.play()

func handle_ascend(delta):
	ascend_timer += delta
	if ascend_timer >= ASCEND_DURATION:
		is_ascending = false
		velocity.y = -2.0 
		move_and_slide()
		return
	var current_y = global_position.y
	if current_y < target_y:
		velocity.y = ASCEND_SPEED
	else:
		velocity.y = 0.0
		global_position.y = target_y + sin(ascend_timer * 0.5) * 0.1
	velocity.x = lerp(velocity.x, 0.0, 5.0 * delta)
	velocity.z = lerp(velocity.z, 0.0, 5.0 * delta)
	move_and_slide()

func die():
	if is_dying or is_dead:
		return
	super.die()
	is_ascending = false
	is_teleporting = false
