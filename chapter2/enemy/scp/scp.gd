extends "res://chapter2/enemy/BaseEnemy.gd"

var is_chasing_player: bool = false

var ATTACK_DISTANCE: float = 2.0
var is_attacking: bool = false

var attack_cooldown: float = 0.0
var ATTACK_COOLDOWN_TIME: float = 1.5

var is_in_player_view: bool = false
var VIEW_ANGLE_THRESHOLD: float = 0.5  # Порог угла между направлением взгляда игрока и направлением на босса
var VIEW_DISTANCE_THRESHOLD: float = 50.0  # Максимальная дистанция, на которой проверяется взгляд

func _ready():
	super._ready()
	if player:
		start_chasing_player()

func _disable_combat_states():
	is_chasing_player = false
	is_attacking = false

func _get_boss_id() -> String:
	return "SCP"

func _process_enemy_behavior(delta):
	check_player_view()
	if not is_on_floor():
		velocity.y -= gravity * delta
	if attack_cooldown > 0:
		attack_cooldown -= delta
	if is_in_player_view:
		velocity.x = 0
		velocity.z = 0
		if not is_on_floor():
			velocity.y -= gravity * delta
		move_and_slide()
		return
	if not is_chasing_player:
		velocity = velocity.lerp(Vector3.ZERO, ACCELERATION * delta)
		move_and_slide()
		return
	if player and not is_attacking:
		if can_attack_player():
			attack_player()
		move_with_navigation(player.global_position, delta)
	move_and_slide()

func can_attack_player() -> bool:
	if not player:
		return false
	if is_in_player_view:
		return false
	var distance_to_player = global_position.distance_to(player.global_position)
	return distance_to_player <= ATTACK_DISTANCE

func start_chasing_player():
	is_chasing_player = true

func stop_chasing_player():
	is_chasing_player = false

func attack_player():
	if not can_attack_player() or is_dead:
		return
	if attack_cooldown <= 0 and not is_attacking:
		if player:
			is_attacking = true
			$hit.pitch_scale = randf_range(4, 6)
			$hit.play()
			if player.has_method("HP"):
				player.HP(100)
			if player.has_method("take_damage"):
				player.take_damage(100)
			attack_cooldown = ATTACK_COOLDOWN_TIME
			await get_tree().create_timer(0.5).timeout
			is_attacking = false

func die():
	if is_dying or is_dead:
		return
	super.die()

func check_player_view():
	if not player:
		is_in_player_view = false
		return
	var camera = player.get_node("head/Camera3D")
	if not camera:
		is_in_player_view = false
		return
	var distance_to_boss = global_position.distance_to(camera.global_position)
	if distance_to_boss > VIEW_DISTANCE_THRESHOLD:
		is_in_player_view = false
		return
	var direction_to_boss = (global_position - camera.global_position).normalized()
	var camera_forward = -camera.global_transform.basis.z
	var dot_product = camera_forward.dot(direction_to_boss)
	is_in_player_view = dot_product > VIEW_ANGLE_THRESHOLD
