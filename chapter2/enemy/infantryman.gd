extends "res://chapter2/enemy/BaseEnemy.gd"

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

func _init():
	should_shatter = true

var is_chasing_player: bool = false
var SPEED: float = 6
var ACCELERATION: float = 5.0
var ROTATION_SPEED: float = 10.0
var last_animation_state: String = ""

var ATTACK_DISTANCE: float = 2.0 
var KNOCKBACK_FORCE: float = 50.0  # Сила отталкивания
var is_attacking: bool = false

var attack_cooldown: float = 0.0
var ATTACK_COOLDOWN_TIME: float = 1.5

#стрельба
var SHOOT_DISTANCE_MIN: float = 3.0  # минимальная дистанция для стрельбы
var SHOOT_DISTANCE_MAX: float = 12.0 # максимальная дистанция для стрельбы
var shoot_timer: float = 0.0
var SHOOT_COOLDOWN: float = 3.5
var is_shooting_mode: bool = false
var bullet_scene = preload("res://chapter2/item/Enemy_projectile/Enemy_projectile.tscn")

var previous_position: Vector3

func _ready():
	super._ready()
	previous_position = global_position
	health = 60
	health *= int(speed_multiplier)
	SPEED *= speed_multiplier
	SHOOT_COOLDOWN /= speed_multiplier
	if is_boss:
		health = 190
		$body/body/Sprite3D.visible = true
	shatter_parts = [
		$body/body,
		$body/hand1,
		$body/hand2
	]
	_setup_boss_bar()
	if player:
		start_chasing_player()
		shoot_timer = 2.0

func _disable_combat_states():
	is_chasing_player = false
	is_attacking = false
	is_shooting_mode = false

func _get_boss_id() -> String:
	return "infantryman"

func _physics_process(delta):
	if Global.game_settings["UI"] or Global.game_settings["GhostMod"]:
		return
	super._physics_process(delta)
	if is_dead or is_dying:
		return
	if not is_on_floor():
		velocity.y -= gravity * delta
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
		var distance_to_player = global_position.distance_to(player.global_position)
		if distance_to_player >= SHOOT_DISTANCE_MIN and distance_to_player <= SHOOT_DISTANCE_MAX:
			is_shooting_mode = true
			if last_animation_state != "shoot_mode":
				$body/run.play_backwards("run")
				$body/AnimationPlayer.play("weapon")
				last_animation_state = "shoot_mode"
			var direction_to_player = (player.global_position - global_position).normalized()
			if direction_to_player.length() > 0.1:
				var target_rotation = atan2(direction_to_player.x, direction_to_player.z)
				rotation.y = lerp_angle(rotation.y, target_rotation, ROTATION_SPEED * delta)
			if shoot_timer <= 0:
				shoot_at_player()
				shoot_timer = SHOOT_COOLDOWN
			else:
				shoot_timer -= delta
			velocity = velocity.lerp(Vector3.ZERO, ACCELERATION * delta)
			move_and_slide()
			return
		is_shooting_mode = false
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
				player.HP(20)
			if player.has_method("take_damage"):
				player.take_damage(20)
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
	var bullet_spawn = $body/BulletSpawn
	if not bullet_spawn:
		return
	var bullet = bullet_scene.instantiate()
	get_tree().root.add_child(bullet)
	bullet.global_position = bullet_spawn.global_position
	var target_pos = player.global_position
	target_pos.y = bullet_spawn.global_position.y
	var shoot_direction = (target_pos - bullet_spawn.global_position).normalized()
	bullet.shoot(shoot_direction, 10.0)
	var audio = $body/hand1/Taser/AudioStreamPlayer3D
	if audio:
		audio.play()

func die():
	if is_dying or is_dead:
		return
	super.die()
