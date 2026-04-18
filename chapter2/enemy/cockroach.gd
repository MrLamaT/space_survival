extends CharacterBody3D

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var health_label: Label3D = $hp

@export var danve = false
@export var is_boss = false
@export var aura = 0

var is_dying: bool = false
var death_timer: float = 0.0
var DEATH_DELAY: float = 1

var player: Node3D = null
var is_running_away: bool = false

# Настройки движения
var SPEED: float = 8
var ACCELERATION: float = 8.0
var run_away_timer: float = 0.0
var RUN_AWAY_TIME: float = 1.5 # Убегает 1.5 секунды, потом телепортируется

# Дистанция атаки
var DETECTION_DISTANCE: float = 10.0

# Телепортация
var is_teleporting: bool = false

var previous_position: Vector3
var movement_direction: Vector3

var is_dead: bool = false
var health: int = 1

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	if danve:
		$body/AnimationPlayer.play("dance")
		$body/Mexico.visible = true
	else:
		$body/Mexico.visible = false
	if !Global.game_settings["Enemy"]:
		queue_free()
		return
	if !Global.game_settings["GhostMod"]:
		player = get_tree().get_first_node_in_group("player")
	previous_position = global_position
	if aura > 0:
		auraSprite()
	update_health_label()
	var boss_bars = get_tree().get_nodes_in_group("BossBar")
	if boss_bars.size() > 0 and is_boss:
		boss_bars[0].setup_boss(health, "spark")

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
	if player and not is_running_away and not is_teleporting:
		var distance_to_player = global_position.distance_to(player.global_position)
		if distance_to_player <= DETECTION_DISTANCE:
			start_running_away()
	if is_running_away and not is_teleporting:
		run_away_timer += delta 
		if run_away_timer >= RUN_AWAY_TIME:
			start_teleportation()
			return
		if player:
			var direction_to_player = (player.global_position - global_position).normalized()
			var flee_direction = -direction_to_player
			var flee_position = global_position + flee_direction * 10.0
			navigation_agent.target_position = flee_position
			var next_position = navigation_agent.get_next_path_position()
			var direction = (next_position - global_position).normalized()
			if direction.length() > 0.1:
				var target_rotation = atan2(direction.x, direction.z)
				rotation.y = lerp_angle(rotation.y, target_rotation, 10.0 * delta)
			var target_velocity = direction * SPEED
			target_velocity.y = velocity.y
			velocity = velocity.lerp(target_velocity, ACCELERATION * delta)
			var current_distance = global_position.distance_to(player.global_position)
			if current_distance > DETECTION_DISTANCE * 2:
				start_teleportation()
	movement_direction = global_position - previous_position
	previous_position = global_position
	move_and_slide()

func start_running_away():
	is_running_away = true

func start_teleportation():
	if is_teleporting or is_dying or is_dead:
		return
	if not is_inside_tree():
		queue_free()
		return
	is_teleporting = true
	velocity = Vector3.ZERO
	$body/AnimationPlayer.stop()
	$body/AnimationPlayer.play("RESET")
	var portal_scene = preload("res://chapter2/wave/WavePortal.tscn")
	var portal_instance = portal_scene.instantiate()
	get_parent().add_child(portal_instance)
	portal_instance.global_position = global_position
	queue_free()

func die():
	if is_dying or is_dead:
		return
	is_dying = true
	death_timer = 0.0
	$shock.pitch_scale = randf_range(0.9, 1.1)
	$shock.play()
	velocity = Vector3.ZERO
	is_running_away = false
	is_teleporting = false

func take_damage(damage):
	if is_dying or is_dead:
		return
	health -= damage
	update_health_label()
	var boss_bars = get_tree().get_nodes_in_group("BossBar")
	if boss_bars.size() > 0 and is_boss:
		boss_bars[0]._on_health_changed(health)
	if health <= 0:
		die()
	else:
		if is_teleporting:
			is_teleporting = false

func update_health_label():
	if health_label:
		health_label.text = str(health) + " HP"
		if health <= 5:
			health_label.modulate = Color(1, 0.3, 0.3) 
		elif health <= 10:
			health_label.modulate = Color(1, 0.8, 0.3)
		else:
			health_label.modulate = Color(1, 1, 1)
