extends "res://chapter2/enemy/BaseEnemy.gd"

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

var is_chasing_player: bool = false
var SPEED: float = 10
var ACCELERATION: float = 5.0
var ROTATION_SPEED: float = 10.0
var last_animation_state: String = ""

var ATTACK_DISTANCE: float = 5.0 
var KNOCKBACK_FORCE: float = 100.0  # Сила отталкивания
var is_attacking: bool = false

var attack_cooldown: float = 0.0
var ATTACK_COOLDOWN_TIME: float = 1.5

var previous_position: Vector3

@export var place = false

func _ready():
	super._ready()
	previous_position = global_position
	health = 400
	health *= int(speed_multiplier)
	SPEED *= speed_multiplier
	shatter_parts = [
		$body/body,
		$body/hand1,
		$body/hand2,
		$body/legs1,
		$body/legs2,
		$body/MeshInstance3D
	]
	_setup_boss_bar()
	if player:
		start_chasing_player()

func _disable_combat_states():
	is_chasing_player = false
	is_attacking = false

func _get_boss_id() -> String:
	return "siren head"

func _process_enemy_behavior(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	if place:
		return
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
	previous_position = global_position
	move_and_slide()

func can_attack_player() -> bool:
	if not player:
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
			$body/AnimationPlayer.play("attack")
			if player.has_method("HP"):
				player.HP(100)
			if player.has_method("take_damage"):
				player.take_damage(100)
			if player is CharacterBody3D:
				var knockback_direction = (player.global_position - global_position).normalized()
				player.velocity.x = knockback_direction.x * KNOCKBACK_FORCE
				player.velocity.z = knockback_direction.z * KNOCKBACK_FORCE
				player.velocity.y = KNOCKBACK_FORCE * 0.1
			attack_cooldown = ATTACK_COOLDOWN_TIME
			await get_tree().create_timer(0.5).timeout
			is_attacking = false

func die():
	if is_dying or is_dead:
		return
	super.die()

func _on_siren_finished() -> void:
	$siren.play()
