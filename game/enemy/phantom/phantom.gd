extends "res://game/enemy/BaseEnemy.gd"

var is_chasing_player: bool = false
var ATTACK_DISTANCE: float = 2.0 

# Настройки прыжка
var chase_timer: float = 0.0
var CHASE_TIMEOUT: float = 2.0
var is_preparing_jump: bool = false
var prepare_jump_timer: float = 0.0
var PREPARE_JUMP_TIME: float = 1.0
var jump_cooldown: float = 0.0
var attack_cooldown: float = 0.0
var ATTACK_COOLDOWN_TIME: float = 1.5

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
	velocity = Vector3.ZERO

func prepare_jump(delta):
	prepare_jump_timer += delta
	if prepare_jump_timer >= PREPARE_JUMP_TIME:
		is_preparing_jump = false
		start_jump_to_player()

func _on_jump_started() -> void:
	chase_timer = 0.0

func _on_jump_landed() -> void:
	is_preparing_jump = false
	if player:
		navigation_agent.target_position = player.global_position

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
