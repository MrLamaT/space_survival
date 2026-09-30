extends "res://game/enemy/BaseEnemy.gd"

var is_chasing_player: bool = false
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
var attack_cooldown: float = 0.0
var ATTACK_COOLDOWN_TIME: float = 1.5
var jump_timeout: float = 0.0
var JUMP_MAX_TIME: float = 2.0 
var JUMP_LAUNCH_SPEED: float = 5.0

func _ready():
	super._ready()
	if player:
		start_chasing_player()

func _disable_combat_states():
	is_chasing_player = false
	is_preparing_jump = false
	is_jumping = false

func _get_boss_id() -> String:
	return "phantom"

func _process_enemy_behavior(delta):
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
		if can_attack_player():
			attack_player()
			chase_timer = 0.0
		if chase_timer >= CHASE_TIMEOUT:
			start_prepare_jump()
			return
		move_with_navigation(player.global_position, delta)
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
	if not player:
		return
	is_jumping = true
	jump_target_position = player.global_position
	jump_timeout = 0.0
	$body/AnimationPlayer.play("jamp")
	chase_timer = 0.0 
	velocity.y = JUMP_LAUNCH_SPEED

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

func can_attack_player() -> bool:
	if not player:
		return false
	var distance_to_player = global_position.distance_to(player.global_position)
	return distance_to_player <= ATTACK_DISTANCE

func start_chasing_player():
	is_chasing_player = true
	chase_timer = 0.0

func stop_chasing_player():
	is_chasing_player = false

func attack_player():
	if not can_attack_player() or is_dead:
		return
	if attack_cooldown <= 0:
		if player:
			$hit.pitch_scale = randf_range(4, 6)
			$body/AnimationPlayer.play("attack")
			if player.has_method("take_damage"):
				player.take_damage(10)
			attack_cooldown = ATTACK_COOLDOWN_TIME
			chase_timer = 0.0

func die():
	if is_dying or is_dead:
		return
	super.die()
	is_chasing_player = false
	is_preparing_jump = false
	is_jumping = false
