extends "res://chapter2/enemy/BaseEnemy.gd"
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

var ROTATION_SPEED: float = 10.0

# Дистанция атаки
var ATTACK_DISTANCE: float = 2.0 
var KNOCKBACK_FORCE: float = 50.0  # Сила отталкивания
var is_attacking: bool = false

var attack_cooldown: float = 0.0
var ATTACK_COOLDOWN_TIME: float = 1.5

#стрельба
var is_shooting_mode: bool = false
var bullet_scene = preload("res://chapter2/item/Phantom_projectile/Phantom_projectile.tscn")
var burst_shots_left: int = 0  # Сколько выстрелов осталось в очереди
var burst_delay: float = 0.0   # Задержка между выстрелами в очереди
var BURST_SHOTS: int = 3       # Количество выстрелов в очереди
var BURST_INTERVAL: float = 0.4 # Интервал между выстрелами
var burst_cooldown: float = 0.0  # Таймер полной задержки
var BURST_COOLDOWN_TIME: float = 2.0  # Полная задержка после очереди

# Прыжок
var is_jumping: bool = false
var jump_target_position: Vector3
var jump_timeout: float = 0.0
var JUMP_MAX_TIME: float = 2.0
var JUMP_LAUNCH_SPEED: float = 5.0
var JUMP_SPEED: float = 12.0
var chase_timer: float = 0.0 
var CHASE_TIMEOUT: float = 2.0

func _ready():
	super._ready()
	health = 40
	health *= int(speed_multiplier)
	BURST_COOLDOWN_TIME /= speed_multiplier
	_setup_boss_bar()
	if player:
		burst_shots_left = BURST_SHOTS
		burst_cooldown = 2.0

func _disable_combat_states():
	is_jumping = false
	is_attacking = false
	is_shooting_mode = false

func _get_boss_id() -> String:
	return "phantom shooter"

func _process_enemy_behavior(delta):
	if is_jumping:
		handle_jump(delta)
		return
	if not is_on_floor():
		velocity.y -= gravity * delta
	if attack_cooldown > 0:
		attack_cooldown -= delta
	if player:
		if is_attacking:
			move_and_slide()
			return
		if not is_shooting_mode:
			is_shooting_mode = true
			$body/AnimationPlayer.play("weapon")
		var direction_to_player = (player.global_position - global_position).normalized()
		if direction_to_player.length() > 0.1:
			var target_rotation = atan2(direction_to_player.x, direction_to_player.z)
			rotation.y = lerp_angle(rotation.y, target_rotation, 10.0 * delta)
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
				if burst_cooldown <= 0:
					start_jump_to_player()
					burst_cooldown = BURST_COOLDOWN_TIME
					burst_shots_left = BURST_SHOTS
		else:
			burst_cooldown -= delta
		if not is_jumping:
			velocity = velocity.lerp(Vector3.ZERO, 5.0 * delta)
		move_and_slide()
		return

func can_attack_player() -> bool:
	if not player:
		return false
	var distance_to_player = global_position.distance_to(player.global_position)
	return distance_to_player <= ATTACK_DISTANCE

func attack_player():
	if is_dead:
		return
	if attack_cooldown <= 0 and not is_attacking:
		if player:
			is_attacking = true
			$hit.pitch_scale = randf_range(4, 6)
			$body/AnimationPlayer.play("attack")
			if player.has_method("HP"):
				player.HP(10)
			if player.has_method("take_damage"):
				player.take_damage(10)
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
	var bullet_spawn1 = $body/BulletSpawn
	if bullet_spawn1:
		var bullet1 = bullet_scene.instantiate()
		get_tree().root.add_child(bullet1)
		bullet1.global_position = bullet_spawn1.global_position
		var target_pos1 = player.global_position
		target_pos1.y = bullet_spawn1.global_position.y
		var shoot_direction1 = (target_pos1 - bullet_spawn1.global_position).normalized()
		bullet1.shoot(shoot_direction1, 10.0)
	var bullet_spawn2 = $body/BulletSpawn2
	if bullet_spawn2:
		var bullet2 = bullet_scene.instantiate()
		get_tree().root.add_child(bullet2)
		bullet2.global_position = bullet_spawn2.global_position
		var target_pos2 = player.global_position
		target_pos2.y = bullet_spawn2.global_position.y
		var shoot_direction2 = (target_pos2 - bullet_spawn2.global_position).normalized()
		bullet2.shoot(shoot_direction2, 10.0)
	var audio = $body/AudioStreamPlayer3D
	if audio:
		audio.play()

func start_jump_to_player():
	if not player:
		return
	is_jumping = true
	jump_target_position = player.global_position
	jump_timeout = 0.0
	$body/AnimationPlayer.play("jamp")
	chase_timer = 0.0
	velocity.y = JUMP_LAUNCH_SPEED

func land_from_jump():
	velocity.x = 0
	velocity.z = 0
	is_jumping = false
	$body/AnimationPlayer.play("RESET")
	if player and can_attack_player():
		attack_player()
	else:
		is_shooting_mode = true
		$body/AnimationPlayer.play("weapon")
		burst_shots_left = BURST_SHOTS
		burst_delay = 0.0
		burst_cooldown = 0.0

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
	is_attacking = false
