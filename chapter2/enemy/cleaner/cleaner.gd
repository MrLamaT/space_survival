extends "res://chapter2/enemy/BaseEnemy.gd"

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

var SPEED: float = 3
var ACCELERATION: float = 3.0
var ROTATION_SPEED: float = 2.0

var current_target_angle: float = 0.0
var start_position: Vector3 = Vector3.ZERO  # Позиция, с которой начал движение
var is_moving_to_target: bool = false
var is_choosing_direction: bool = false
var is_rotating: bool = false
var MOVE_DISTANCE: float = 5.0  # Дистанция движения перед сменой направления
var ANGLE_CHANGE_COOLDOWN: float = 0.0
var ANGLE_CHOOSE_DELAY: float = 0.5  # Уменьшил задержку
var ROTATION_TOLERANCE: float = 0.05  # Допустимая погрешность поворота (в радианах)

var previous_position: Vector3
var stuck_timer: float = 0.0
var STUCK_TIME: float = 0.5

var spring = false

func _ready():
	super._ready()
	previous_position = global_position
	health = 40
	health *= int(speed_multiplier)
	SPEED *= speed_multiplier
	ROTATION_SPEED *= speed_multiplier
	shatter_parts = [
		$body/Node3D,
		$body/Node3D2
	]
	_setup_boss_bar()
	choose_new_direction()

func _disable_combat_states():
	is_moving_to_target = false
	is_choosing_direction = false
	is_rotating = false

func _get_boss_id() -> String:
	return "drone cleaner"

func _process_enemy_behavior(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	if ANGLE_CHANGE_COOLDOWN > 0:
		ANGLE_CHANGE_COOLDOWN -= delta
	if is_moving_to_target and not is_choosing_direction:
		var target_direction = Vector3(sin(deg_to_rad(current_target_angle)), 0, cos(deg_to_rad(current_target_angle)))
		var target_rotation_y = atan2(target_direction.x, target_direction.z)
		var angle_diff = abs(angle_difference(rotation.y, target_rotation_y))
		if angle_diff > ROTATION_TOLERANCE and not is_rotating:
			is_rotating = true
		if is_rotating:
			rotation.y = lerp_angle(rotation.y, target_rotation_y, ROTATION_SPEED * delta)
			velocity = velocity.lerp(Vector3.ZERO, ACCELERATION * delta)
			var new_angle_diff = abs(angle_difference(rotation.y, target_rotation_y))
			if new_angle_diff <= ROTATION_TOLERANCE:
				is_rotating = false
				start_position = global_position  
		else:
			var distance_traveled = global_position.distance_to(start_position)
			var movement = global_position - previous_position
			var speed = movement.length() / delta
			if speed < 0.5 and is_moving_to_target:
				stuck_timer += delta
				if stuck_timer >= STUCK_TIME:
					is_moving_to_target = false
					choose_new_direction()
					stuck_timer = 0.0
			else:
				stuck_timer = 0.0
			if distance_traveled >= MOVE_DISTANCE:
				is_moving_to_target = false
				choose_new_direction()
			else:
				var target_velocity = target_direction * SPEED
				target_velocity.y = velocity.y
				velocity = velocity.lerp(target_velocity, ACCELERATION * delta)
	elif not is_choosing_direction and ANGLE_CHANGE_COOLDOWN <= 0:
		choose_new_direction()
	else:
		velocity = velocity.lerp(Vector3.ZERO, ACCELERATION * delta)
	previous_position = global_position
	move_and_slide()

func choose_new_direction():
	if is_choosing_direction:
		return
	is_choosing_direction = true
	ANGLE_CHANGE_COOLDOWN = ANGLE_CHOOSE_DELAY
	current_target_angle = randf_range(0, 360)
	is_moving_to_target = true
	is_rotating = true 
	is_choosing_direction = false
	stuck_timer = 0.0

func angle_difference(angle1: float, angle2: float) -> float:
	var diff = fmod(angle2 - angle1, PI * 2)
	if diff > PI:
		diff -= PI * 2
	elif diff < -PI:
		diff += PI * 2
	return diff

func die():
	if is_dying or is_dead:
		return
	super.die()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		_activate_spring(body)

func _activate_spring(body: CharacterBody3D):
	if spring:
		return
	spring = true
	$AudioStreamPlayer3D.play()
	$body/Node3D2/Expectation.visible = false
	var jump_velocity = 8.5  # Сила прыжка
	body.velocity.y = jump_velocity
	var horizontal_force = Vector3(
		randf_range(-2.0, 2.0),
		0,
		randf_range(-2.0, 2.0)
	) * 0.5
	body.velocity += horizontal_force
	take_damage(40)
