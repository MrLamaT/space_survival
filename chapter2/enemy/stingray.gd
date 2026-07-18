extends "res://chapter2/enemy/BaseEnemy.gd"

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var beam_animation: AnimationPlayer = $BulletSpawn/AnimationPlayer
@onready var bullet_spawn: Node3D = $BulletSpawn

var death_rotation: float = 0.0
var SPEED: float = 10.0
var ACCELERATION: float = 5.0
var ROTATION_SPEED: float = 8.0
var FLY_HEIGHT_OFFSET: float = 1.5 # Высота над головой игрока
var TARGET_UPDATE_INTERVAL: float = 0.3
var target_update_timer: float = 0.0

var is_chasing: bool = false
var current_target_position: Vector3
var target_height: float = 0.0

enum AttackState { IDLE, CHARGING, SHOOTING, COOLDOWN }
var attack_state: AttackState = AttackState.IDLE
var state_timer: float = 0.0
var IDLE_DURATION: float = 4.0
var CHARGE_DURATION: float = 5.0
var SHOOT_DURATION: float = 4.0
var is_attacking: bool = false

var bullet_scene = load("res://chapter2/item/beam_projectile/Beam_projectile.tscn")

func _ready():
	double_damage_in_air = false
	super._ready()
	health = 200
	health *= int(speed_multiplier)
	SPEED *= speed_multiplier
	IDLE_DURATION /= speed_multiplier
	CHARGE_DURATION /= speed_multiplier
	SHOOT_DURATION /= speed_multiplier
	_setup_boss_bar()
	gravity = 0.0
	if player:
		start_chasing()
	attack_state = AttackState.IDLE
	state_timer = 0.0

func _get_boss_id() -> String:
	return "stingray"

func start_chasing():
	is_chasing = true
	current_target_position = global_position

func stop_chasing():
	is_chasing = false

func _physics_process(delta):
	if Global.game_settings["UI"] or Global.game_settings["GhostMod"]:
		return
	super._physics_process(delta)
	if is_dead:
		return
	if is_dying:
		_handle_death_process(delta)
		return
	if is_chasing and player and attack_state != AttackState.SHOOTING:
		target_update_timer += delta
		if target_update_timer >= TARGET_UPDATE_INTERVAL:
			target_update_timer = 0.0
			_update_target_position()
		_move_towards_target(delta)
	else:
		if attack_state == AttackState.SHOOTING:
			velocity = velocity.lerp(Vector3.ZERO, ACCELERATION * delta)
	_handle_attack_cycle(delta)
	move_and_slide()

func _update_target_position():
	if not player:
		return
	var player_pos = player.global_position
	var player_height = 1.8
	target_height = player_pos.y + player_height + FLY_HEIGHT_OFFSET
	current_target_position = Vector3(
		player_pos.x,
		target_height,
		player_pos.z
	)
	if navigation_agent:
		navigation_agent.target_position = current_target_position

func _move_towards_target(delta):
	var current_pos = global_position
	var direction = (current_target_position - current_pos).normalized()
	var distance = current_pos.distance_to(current_target_position)
	if distance < 0.5:
		velocity = velocity.lerp(Vector3.ZERO, ACCELERATION * delta)
		return
	if direction.length() > 0.1:
		var target_rotation = atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_rotation, ROTATION_SPEED * delta)
	var target_velocity = direction * SPEED
	velocity = velocity.lerp(target_velocity, ACCELERATION * delta)

func _handle_attack_cycle(delta):
	if not player:
		return
	state_timer += delta
	match attack_state:
		AttackState.IDLE:
			if state_timer >= IDLE_DURATION:
				attack_state = AttackState.CHARGING
				state_timer = 0.0
				beam_animation.play("beam")
				_update_target_position()
		AttackState.CHARGING:
			if state_timer >= CHARGE_DURATION and not is_attacking:
				is_attacking = true
				velocity = Vector3.ZERO
			if state_timer >= CHARGE_DURATION:
				attack_state = AttackState.SHOOTING
				state_timer = 0.0
				beam_animation.play("RESET")
				var bullet_instance = bullet_scene.instantiate()
				get_tree().root.add_child(bullet_instance)
				bullet_instance.global_position = bullet_spawn.global_position
		AttackState.SHOOTING:
			if state_timer >= SHOOT_DURATION:
				attack_state = AttackState.IDLE
				state_timer = 0.0
				is_attacking = false
				if player:
					_update_target_position()

func _handle_death_process(delta):
	if not is_on_floor():
		velocity.y -= 98.0 * delta
	if is_on_floor():
		is_dead = true
		_spawn_boom_projectile()
		queue_free()
		return
	death_timer += delta
	var progress = min(death_timer / DEATH_DELAY, 1.0)
	death_rotation = progress * 90.0
	rotation_degrees.x = death_rotation
	velocity = velocity.lerp(Vector3.ZERO, ACCELERATION * delta * 0.5)
	move_and_slide()

func _spawn_boom_projectile():
	var boom_scene = load("res://chapter2/item/Boom_projectile/Boom_projectile.tscn")
	if boom_scene:
		var boom_instance = boom_scene.instantiate()
		get_tree().root.add_child(boom_instance)
		boom_instance.global_position = bullet_spawn.global_position

func die():
	if is_dying or is_dead:
		return
	super.die()
	death_rotation = 0.0
	is_attacking = false
	if beam_animation:
		beam_animation.stop()

func take_damage(damage: int):
	if is_dying or is_dead:
		return
	health -= damage
	$spark.emitting = true
	if is_boss:
		var boss_bars = get_tree().get_nodes_in_group("BossBar")
		if boss_bars.size() > 0:
			boss_bars[0]._on_health_changed(health)
	if health <= 0:
		if spark_dead:
			spark_dead.emitting = true
		die()
