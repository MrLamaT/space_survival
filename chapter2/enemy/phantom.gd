extends CharacterBody3D

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var health_label: Label3D = $hp

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

# Дистанция атаки
var ATTACK_DISTANCE: float = 2.0 

# Настройки прыжка
var chase_timer: float = 0.0
var CHASE_TIMEOUT: float = 2.0
var is_preparing_jump: bool = false
var prepare_jump_timer: float = 0.0
var PREPARE_JUMP_TIME: float = 1.0
var JUMP_SPEED: float = 15.0  # Скорость прыжка
var is_jumping: bool = false
var jump_target_position: Vector3
var jump_cooldown: float = 0.0

var previous_position: Vector3
var movement_direction: Vector3
var spawnpoint: Vector3

var is_dead: bool = false
var health: int = 20

var attack_cooldown: float = 0.0
var ATTACK_COOLDOWN_TIME: float = 1.5

var jump_timeout: float = 0.0
var JUMP_MAX_TIME: float = 2.0 

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	if !Global.game_settings["Enemy"]:
		queue_free()
		return
	if !Global.game_settings["GhostMod"]:
		player = get_tree().get_first_node_in_group("player")
	previous_position = global_position
	current_target = null
	update_health_label()
	if player:
		start_chasing_player()

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
		velocity = velocity.lerp(Vector3.ZERO, ACCELERATION * delta)
		move_and_slide()
		if death_timer >= DEATH_DELAY:
			is_dead = true
			queue_free()
		return
	if not is_on_floor():
		velocity.y -= gravity * delta
	if attack_cooldown > 0:
		attack_cooldown -= delta
	if is_jumping:
		handle_jump(delta)
		return
	if is_preparing_jump:
		prepare_jump(delta)
		return
	if not is_chasing_player:
		velocity = velocity.lerp(Vector3.ZERO, ACCELERATION * delta)
		move_and_slide()
		return
	if player:
		chase_timer += delta
		navigation_agent.target_position = player.global_position
		if can_attack_player():
			attack_player()
			chase_timer = 0.0
		if chase_timer >= CHASE_TIMEOUT:
			$body/AnimationPlayer.play("scream")
			start_prepare_jump()
			return
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

func start_prepare_jump():
	is_preparing_jump = true
	prepare_jump_timer = 0.0
	velocity = Vector3.ZERO  # Останавливаемся

func prepare_jump(delta):
	prepare_jump_timer += delta
	if prepare_jump_timer >= PREPARE_JUMP_TIME:
		is_preparing_jump = false
		start_jump_to_player()

func start_jump_to_player():
	is_jumping = true
	jump_target_position = player.global_position
	jump_timeout = 0.0
	$body/AnimationPlayer.play("jamp")
	chase_timer = 0.0  # Сбрасываем таймер после прыжка

func land_from_jump():
	is_jumping = false
	is_preparing_jump = false
	$body/AnimationPlayer.play("RESET")
	if player:
		navigation_agent.target_position = player.global_position

func handle_jump(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	jump_timeout += delta
	if jump_timeout >= JUMP_MAX_TIME:
		land_from_jump()
		return
	var horizontal_direction = (jump_target_position - global_position).normalized()
	horizontal_direction.y = 0
	horizontal_direction = horizontal_direction.normalized()
	if horizontal_direction.length() > 0.1:
		var target_rotation = atan2(horizontal_direction.x, horizontal_direction.z)
		rotation.y = lerp_angle(rotation.y, target_rotation, ROTATION_SPEED * delta * 2)
	var horizontal_velocity = horizontal_direction * JUMP_SPEED
	velocity.x = horizontal_velocity.x
	velocity.z = horizontal_velocity.z
	var distance_to_target = global_position.distance_to(jump_target_position)
	if distance_to_target < 1.0 or is_on_floor() and distance_to_target < 2.0:
		land_from_jump()
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
	chase_timer = 0.0

func stop_chasing_player():
	is_chasing_player = false
	current_target = null

func attack_player():
	if not can_attack_player() or is_dead:
		return
	if attack_cooldown <= 0:
		if player:
			$hit.pitch_scale = randf_range(4, 6)
			$body/AnimationPlayer.play("attack")
			if player.has_method("HP"):
				player.HP(10)
			if player.has_method("take_damage"):
				player.take_damage(10)
			attack_cooldown = ATTACK_COOLDOWN_TIME
			chase_timer = 0.0

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
	is_preparing_jump = false
	is_jumping = false

func take_damage(damage):
	health -= damage
	update_health_label()
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
