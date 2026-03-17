extends CharacterBody3D

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var vision_area: Area3D = $VisionArea

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
var health: int = 50

var attack_cooldown: float = 0.0
var ATTACK_COOLDOWN_TIME: float = 1.5

var jump_timeout: float = 0.0
var JUMP_MAX_TIME: float = 2.0 

func _ready():
	if !Global.game_settings["Enemy"]:
		queue_free()
		return
	player = get_tree().get_first_node_in_group("player")
	previous_position = global_position
	current_target = null

func _physics_process(delta):
	if is_dead:
		return
	if is_dying:
		death_timer += delta
		velocity = velocity.lerp(Vector3.ZERO, ACCELERATION * delta)
		move_and_slide()
		if death_timer >= DEATH_DELAY:
			is_dead = true
			queue_free()
		return
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
	jump_timeout += delta
	if jump_timeout >= JUMP_MAX_TIME:
		land_from_jump()
		return
	var direction = (jump_target_position - global_position).normalized()
	if direction.length() > 0.1:
		var target_rotation = atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_rotation, ROTATION_SPEED * delta * 2)
	velocity = direction * JUMP_SPEED
	var distance_to_target = global_position.distance_to(jump_target_position)
	if distance_to_target < 1.0 or is_on_floor() and distance_to_target < 2.0:
		land_from_jump()
	move_and_slide()

func can_attack_player() -> bool:
	if not player or Global.game_settings["GodMod"]:
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
		if player and player.has_method("HP"):
			$body/AnimationPlayer.play("attack")
			player.HP(10)
			attack_cooldown = ATTACK_COOLDOWN_TIME
			chase_timer = 0.0

func die():
	if is_dying or is_dead:
		return
	is_dying = true
	death_timer = 0.0
	$sparkDead.emitting = true
	velocity = Vector3.ZERO
	is_chasing_player = false
	is_preparing_jump = false
	is_jumping = false

func _on_vision_area_body_entered(body):
	if body.is_in_group("player"):
		player = body
		start_chasing_player()
		
func take_damage(damage):
	health -= damage
	if health <= 0:
		$sparkDead.emitting = true
		die()
	else:
		$spark.emitting = true
