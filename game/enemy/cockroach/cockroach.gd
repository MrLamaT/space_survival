extends "res://game/enemy/BaseEnemy.gd"

var is_running_away: bool = false
var run_away_timer: float = 0.0
var RUN_AWAY_TIME: float = 1.5 # Убегает 1.5 секунды, потом телепортируется
var DETECTION_DISTANCE: float = 10.0
var is_teleporting: bool = false

func _disable_combat_states():
	is_running_away = false
	is_teleporting = false

func _get_boss_id() -> String:
	return "spark"

func _process_enemy_behavior(delta):
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
			move_with_navigation(flee_position, delta)
			var current_distance = global_position.distance_to(player.global_position)
			if current_distance > DETECTION_DISTANCE * 2:
				start_teleportation()
	move_and_slide()

func _handle_death_process(delta):
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
	var portal_instance = PORTAL_SCENE.instantiate()
	get_parent().add_child(portal_instance)
	portal_instance.global_position = global_position
	queue_free()

func die():
	if is_dying or is_dead:
		return
	super.die()
	is_running_away = false
	is_teleporting = false

func take_damage(damage: int):
	if is_dying or is_dead:
		return
	super.take_damage(damage)
	if is_teleporting:
		is_teleporting = false
