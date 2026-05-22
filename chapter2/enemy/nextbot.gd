extends "res://chapter2/enemy/BaseEnemy.gd"

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

var is_chasing_player: bool = false
var SPEED: float = 4
var ACCELERATION: float = 5.0
var ROTATION_SPEED: float = 10.0
var ATTACK_DISTANCE: float = 3.0 
var attack_cooldown: float = 0.0
var ATTACK_COOLDOWN_TIME: float = 1.5
var previous_position: Vector3

func _ready():
	super._ready()
	previous_position = global_position
	health = 100000
	if aura > 0:
		health *= aura + 1
	_setup_boss_bar()
	var bot_images = [
		"res://assets/Nextbot/bot1.jpg",
		"res://assets/Nextbot/bot2.jpg",
		"res://assets/Nextbot/bot3.jpg",
		"res://assets/Nextbot/bot4.jpg",
		"res://assets/Nextbot/bot5.jpg"
	]
	var random_bot = bot_images[randi() % bot_images.size()]
	var bot_texture = load(random_bot)
	$body/Sprite3D.texture = bot_texture
	if player:
		start_chasing_player()

func _apply_aura():
	super._apply_aura()
	SPEED *= speed_multiplier

func _disable_combat_states():
	is_chasing_player = false

func _get_boss_id() -> String:
	return "nextbot"

func _physics_process(delta):
	if is_dead:
		return
	if is_dying:
		_handle_death_process(delta)
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
	if attack_cooldown <= 0:
		if player:
			$hit.pitch_scale = randf_range(4, 6)
			$hit.play()
			if player.has_method("HP"):
				player.HP(100000)
			if player.has_method("take_damage"):
				player.take_damage(100000)
			take_damage(100000)
			attack_cooldown = ATTACK_COOLDOWN_TIME

func die():
	if is_dying or is_dead:
		return
	super.die()
	is_chasing_player = false
