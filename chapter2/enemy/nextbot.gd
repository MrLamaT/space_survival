extends CharacterBody3D

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var health_label: Label3D = $hp

@export var is_boss = false
@export var aura = 0

var is_dying: bool = false
var death_timer: float = 0.0
var DEATH_DELAY: float = 1

var current_target: Node3D = null
var player: Node3D = null
var is_chasing_player: bool = false

# Настройки движения
var SPEED: float = 4
var ACCELERATION: float = 5.0
var ROTATION_SPEED: float = 10.0

# Дистанция атаки
var ATTACK_DISTANCE: float = 3.0 

var previous_position: Vector3
var movement_direction: Vector3
var spawnpoint: Vector3

var is_dead: bool = false
var health: int = 100000

var attack_cooldown: float = 0.0
var ATTACK_COOLDOWN_TIME: float = 1.5

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	if !Global.game_settings["Enemy"]:
		queue_free()
		return
	if !Global.game_settings["GhostMod"]:
		player = get_tree().get_first_node_in_group("player")
	previous_position = global_position
	current_target = null
	if aura > 0:
		auraSprite()
	update_health_label()
	var boss_bars = get_tree().get_nodes_in_group("BossBar")
	if boss_bars.size() > 0 and is_boss:
		boss_bars[0].setup_boss(health, "nextbot")
	var bot_images = [
		"res://assets/Nextbot/bot1.jpg",
		"res://assets/Nextbot/bot2.jpg",
		"res://assets/Nextbot/bot3.jpg",
		"res://assets/Nextbot/bot4.jpg"
	]
	var random_bot = bot_images[randi() % bot_images.size()]
	var bot_texture = load(random_bot)
	$body/Sprite3D.texture = bot_texture
	if player:
		start_chasing_player()

func auraSprite():
	$Aura/AnimationPlayer.play("aura")
	if aura == 1:
		$Aura.modulate = Color("#ff7a01")
	else:
		$Aura.modulate = Color("#f50000")
	SPEED *= aura + 1
	health *= aura + 1

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
	movement_direction = global_position - previous_position
	previous_position = global_position
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

func stop_chasing_player():
	is_chasing_player = false
	current_target = null

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
	is_dying = true
	death_timer = 0.0
	$sparkDead.emitting = true
	$shock.pitch_scale = randf_range(0.9, 1.1)
	$shock.play()
	velocity = Vector3.ZERO
	is_chasing_player = false

func take_damage(damage):
	health -= damage
	if not is_on_floor():
		health -= damage
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
