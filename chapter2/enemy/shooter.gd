extends CharacterBody3D

@onready var health_label: Label3D = $hp

@export var is_boss = false
@export var aura = 0

var is_dying: bool = false
var death_timer: float = 0.0
var DEATH_DELAY: float = 1

var player: Node3D = null

# Дистанция атаки
var ATTACK_DISTANCE: float = 2.0 
var KNOCKBACK_FORCE: float = 50.0  # Сила отталкивания
var is_attacking: bool = false

var is_dead: bool = false
var health: int = 40

var attack_cooldown: float = 0.0
var ATTACK_COOLDOWN_TIME: float = 1.5

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

#стрельба
var is_shooting_mode: bool = false
var bullet_scene = preload("res://chapter2/item/Phantom_projectile/Phantom_projectile.tscn")
var burst_shots_left: int = 0  # Сколько выстрелов осталось в очереди
var burst_delay: float = 0.0   # Задержка между выстрелами в очереди
var BURST_SHOTS: int = 3       # Количество выстрелов в очереди
var BURST_INTERVAL: float = 0.4 # Интервал между выстрелами
var burst_cooldown: float = 0.0  # Таймер полной задержки
var BURST_COOLDOWN_TIME: float = 3.5  # Полная задержка после очереди

# Прыжок
var is_jumping: bool = false
var jump_target_position: Vector3
var jump_timeout: float = 0.0
var JUMP_MAX_TIME: float = 2.0
var JUMP_LAUNCH_SPEED: float = 5.0
var JUMP_SPEED: float = 15.0
var is_preparing_jump: bool = false
var prepare_jump_timer: float = 0.0
var PREPARE_JUMP_TIME: float = 1.0

func _ready():
	if !Global.game_settings["Enemy"]:
		queue_free()
		return
	if !Global.game_settings["GhostMod"]:
		player = get_tree().get_first_node_in_group("player")
	if aura > 0:
		auraSprite()
	update_health_label()
	var boss_bars = get_tree().get_nodes_in_group("BossBar")
	if boss_bars.size() > 0 and is_boss:
		boss_bars[0].setup_boss(health, "phantom shooter")
	if player:
		burst_shots_left = BURST_SHOTS
		burst_cooldown = 2.0

func auraSprite():
	$Aura/AnimationPlayer.play("aura")
	if aura == 1:
		$Aura.modulate = Color("#ff7a01")
	else:
		$Aura.modulate = Color("#f50000")
	health *= aura + 1
	BURST_COOLDOWN_TIME /= aura + 1

func _physics_process(delta):
	if is_dead:
		return
	if is_dying:
		death_timer += delta
		var shake_intensity = 0.05 * (1.0 - death_timer / DEATH_DELAY)
		var shake_offset = Vector3(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity)
		)
		global_position += shake_offset
		if death_timer >= DEATH_DELAY:
			is_dead = true
			queue_free()
		return
	if is_jumping:
		handle_jump(delta)
		return
	if is_preparing_jump:
		prepare_jump(delta)
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
					start_prepare_jump()
					burst_cooldown = BURST_COOLDOWN_TIME
					burst_shots_left = BURST_SHOTS
		else:
			burst_cooldown -= delta
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
	var bullet_spawn1 = $body/hand1/BulletSpawn
	if bullet_spawn1:
		var bullet1 = bullet_scene.instantiate()
		get_tree().root.add_child(bullet1)
		bullet1.global_position = bullet_spawn1.global_position
		var target_pos1 = player.global_position
		target_pos1.y = bullet_spawn1.global_position.y
		var shoot_direction1 = (target_pos1 - bullet_spawn1.global_position).normalized()
		bullet1.shoot(shoot_direction1, 10.0)
	var bullet_spawn2 = $body/hand2/BulletSpawn
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

func start_prepare_jump():
	is_preparing_jump = true
	prepare_jump_timer = 0.0
	is_shooting_mode = false
	$body/AnimationPlayer.play("RESET")
	velocity = Vector3.ZERO

func prepare_jump(delta):
	if not is_preparing_jump:
		return
	prepare_jump_timer += delta
	if prepare_jump_timer >= PREPARE_JUMP_TIME:
		is_preparing_jump = false
		start_jump_to_player()

func start_jump_to_player():
	if not player:
		return
	is_jumping = true
	jump_target_position = player.global_position
	jump_timeout = 0.0
	$body/AnimationPlayer.play("jamp")
	velocity.y = JUMP_LAUNCH_SPEED

func land_from_jump():
	is_jumping = false
	is_preparing_jump = false
	$body/AnimationPlayer.play("RESET")
	burst_shots_left = BURST_SHOTS
	burst_delay = 0.0
	if player and can_attack_player():
		attack_player()

func handle_jump(delta):
	if not player:
		land_from_jump()
		return
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
		rotation.y = lerp_angle(rotation.y, target_rotation, 10.0 * delta * 2)
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
	is_dying = true
	death_timer = 0.0
	$sparkDead.emitting = true
	$shock.pitch_scale = randf_range(0.9, 1.1)
	$shock.play()
	velocity = Vector3.ZERO
	is_preparing_jump = false
	is_jumping = false

func take_damage(damage):
	health -= damage
	if not is_on_floor():
		health -= damage
	if is_jumping or is_preparing_jump:
		land_from_jump()
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
