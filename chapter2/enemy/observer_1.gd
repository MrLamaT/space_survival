extends "res://chapter2/enemy/BaseEnemy.gd"
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@export var watch = false

var ROTATION_SPEED: float = 10.0

# Стрельба
var bullet_scene = preload("res://chapter2/item/Homing_projectile/Homing_projectile.tscn")
var burst_shots_left: int = 0
var burst_delay: float = 0.0
var BURST_SHOTS: int = 3
var BURST_INTERVAL: float = 0.4
var burst_cooldown: float = 0.0
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

var attack_system = {
	AttackType.SHOOT: {
		"cd": 0.0,
		"cd_max": 5.0,
		"anim": "weapon"
	},
	AttackType.JUMP: {
		"cd": 0.0,
		"cd_max": 7.5,
		"anim": "jump"
	},
	AttackType.TELEPORT: {
		"cd": 0.0,
		"cd_max": 2.0,
		"anim": "RESET"
	}
}

var action_delay: float = 0.0  # Задержка между действиями

func _ready():
	super._ready()
	health = 200
	if aura > 0:
		health *= aura + 1
		BURST_COOLDOWN_TIME /= (aura + 1)
	_setup_boss_bar()
	burst_shots_left = BURST_SHOTS

func _apply_aura():
	super._apply_aura()
	BURST_COOLDOWN_TIME /= speed_multiplier

func _disable_combat_states():
	is_jumping = false

func _get_boss_id() -> String:
	return "phantom observer"

func _physics_process(delta):
	if watch:
		if player and global_position.distance_to(player.global_position) < 10.0:
			create_portal(global_position)
			queue_free()
		move_and_slide()
		return
	if Global.game_settings["UI"] or Global.game_settings["GhostMod"]:
		return
	if is_dead or is_dying:
		if is_dying:
			_handle_death_process(delta)
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
	# Обновляем кулдауны
	if action_delay > 0:
		action_delay -= delta
	for a in attack_system.values():
		if a["cd"] > 0:
			a["cd"] -= delta
	if not player:
		move_and_slide()
		return
	# Поворот к игроку
	var direction_to_player = (player.global_position - global_position).normalized()
	if direction_to_player.length() > 0.1:
		var target_rotation = atan2(direction_to_player.x, direction_to_player.z)
		rotation.y = lerp_angle(rotation.y, target_rotation, ROTATION_SPEED * delta)
	# Обработка стрельбы очередью
	if burst_cooldown <= 0:
		if burst_shots_left > 0:
			if burst_delay <= 0:
				shoot_at_player()
				burst_shots_left -= 1
				if burst_shots_left > 0:
					burst_delay = BURST_INTERVAL
				else:
					burst_cooldown = BURST_COOLDOWN_TIME
			else:
				burst_delay -= delta
		else:
			burst_cooldown = BURST_COOLDOWN_TIME
			burst_shots_left = BURST_SHOTS
	else:
		burst_cooldown -= delta
	# Телепорт 
	var dist_to_player = global_position.distance_to(player.global_position)
	if not is_teleporting and not is_jumping and attack_system[AttackType.TELEPORT]["cd"] <= 0:
		if dist_to_player <= DISTANCE_MIN or dist_to_player >= DISTANCE_MAX:
			teleport_to_ideal_distance()
			return
	# Выбор случайной атаки
	if action_delay <= 0 and not is_jumping and not is_teleporting and burst_cooldown <= 0:
		var ready_attacks = []
		for t in AttackType.values():
			if attack_system[t]["cd"] <= 0:
				ready_attacks.append(t)
		if ready_attacks.size() > 0:
			var chosen = ready_attacks[randi() % ready_attacks.size()]
			match chosen:
				AttackType.SHOOT:
					do_shoot()
				AttackType.JUMP:
					do_jump()
				AttackType.TELEPORT:
					do_teleport()
	# Движение
	if not is_jumping and not is_teleporting:
		velocity = velocity.lerp(Vector3.ZERO, 5.0 * delta)
	move_and_slide()

# === ДЕЙСТВИЯ ===
func do_shoot():
	$body/AnimationPlayer.play(attack_system[AttackType.SHOOT]["anim"])
	attack_system[AttackType.SHOOT]["cd"] = attack_system[AttackType.SHOOT]["cd_max"]
	action_delay = 1.0
	burst_shots_left = BURST_SHOTS
	burst_cooldown = 0.0
	burst_delay = 0.0

func do_jump():
	$body/AnimationPlayer.play(attack_system[AttackType.JUMP]["anim"])
	attack_system[AttackType.JUMP]["cd"] = attack_system[AttackType.JUMP]["cd_max"]
	action_delay = 1.0
	start_jump_to_player()

func do_teleport():
	$body/AnimationPlayer.play(attack_system[AttackType.TELEPORT]["anim"])
	attack_system[AttackType.TELEPORT]["cd"] = attack_system[AttackType.TELEPORT]["cd_max"]
	action_delay = 1.0
	teleport_near_player()

func teleport_to_ideal_distance():
	if not player or is_teleporting:
		return
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
	attack_system[AttackType.TELEPORT]["cd"] = attack_system[AttackType.TELEPORT]["cd_max"]

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
