extends CharacterBody3D

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var vision_area: Area3D = $VisionArea
@onready var state_label: Label3D = $StateLabel
@onready var shock_timer: Timer = $shock_timer
@onready var shock_animation_timer: Timer = $shock_animation_timer

var sprite_3d_old: AnimatedSprite3D
var sprite_3d_new: AnimatedSprite3D
var sprite_3d: AnimatedSprite3D

var current_target: Node3D = null
var player: Node3D = null
var is_chasing_player: bool = false

# Настройки движения
var SPEED: float = 3.0
var ACCELERATION: float = 5.0
var ROTATION_SPEED: float = 10.0

# Таймер для потери игрока
var player_hide_timer: float = 0.0
var player_hide_timeout: float = 3.0
var was_player_hidden: bool = false

# Дистанция атаки
var ATTACK_DISTANCE: float = 2.0  

var previous_position: Vector3
var movement_direction: Vector3
var spawnpoint: Vector3

var is_shocked: bool = false

func _ready():
	if Global.game_settings["ModScar"]:
		print("scar delet")
		queue_free()
		return
	initialize_sprites()
	print("scar speed: ", SPEED)
	player = get_tree().get_first_node_in_group("player")
	find_target()
	update_state_label("Patrolling")
	previous_position = global_position
	sprite_3d.play("idle_front")
	spawnpoint = global_position

func initialize_sprites():
	sprite_3d_old = get_node_or_null("AnimatedSprite3D_old")
	sprite_3d_new = get_node_or_null("AnimatedSprite3D_new")
	if Global.game_settings["ModSkin"]:
		sprite_3d = sprite_3d_old
		if sprite_3d_new:
			sprite_3d_new.queue_free()
			sprite_3d_new = null
	else:
		sprite_3d = sprite_3d_new
		if sprite_3d_old:
			sprite_3d_old.queue_free()
			sprite_3d_old = null
	if not sprite_3d:
		push_error("No valid sprite found for eye enemy!")
		queue_free()

func _physics_process(delta):
	if is_shocked:
		move_and_slide()
		return
	if not current_target:
		return
	navigation_agent.target_position = current_target.global_position
	if is_chasing_player and player and can_attack_player():
		attack_player()
		return
	if navigation_agent.is_navigation_finished():
		if is_chasing_player:
			if can_attack_player():
				attack_player()
			else:
				lose_player()
		else:
			find_target()
		return
	if is_chasing_player and player:
		check_player_hidden(delta)
	var next_position = navigation_agent.get_next_path_position()
	var direction = (next_position - global_position).normalized()
	if direction.length() > 0.1:
		var target_rotation = atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_rotation, ROTATION_SPEED * delta)
	var target_velocity = direction * SPEED
	velocity = velocity.lerp(target_velocity, ACCELERATION * delta)
	movement_direction = global_position - previous_position
	update_sprite_animation()
	previous_position = global_position
	move_and_slide()

func update_sprite_animation():
	if is_shocked:
		return
	if movement_direction.length() < 0.01:
		if sprite_3d.animation.begins_with("walk_"):
			var direction = sprite_3d.animation.replace("walk_", "")
			sprite_3d.play("idle_" + direction)
		return
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return
	var to_camera = camera.global_position - global_position
	to_camera.y = 0
	to_camera = to_camera.normalized()
	var move_dir = movement_direction.normalized()
	var dot_product = to_camera.dot(move_dir)
	if dot_product > 0:
		if not sprite_3d.animation == "walk_front" and not sprite_3d.animation == "idle_front":
			sprite_3d.play("walk_front")
	else:
		if not sprite_3d.animation == "walk_back" and not sprite_3d.animation == "idle_back":
			sprite_3d.play("walk_back")

func can_attack_player() -> bool:
	if not player or Global.game_settings["HidePlayer"]:
		return false
	var distance_to_player = global_position.distance_to(player.global_position)
	return distance_to_player <= ATTACK_DISTANCE

func check_player_hidden(delta):
	if Global.game_settings["HidePlayer"]:
		if not was_player_hidden:
			was_player_hidden = true
			player_hide_timer = 0.0
			update_state_label("Lost Player?")
		else:
			player_hide_timer += delta
			if player_hide_timer >= player_hide_timeout:
				lose_player()
	else:
		if was_player_hidden:
			was_player_hidden = false
			player_hide_timer = 0.0
			update_state_label("Chasing Player")

func lose_player():
	is_chasing_player = false
	was_player_hidden = false
	player_hide_timer = 0.0
	
	find_target()
	update_state_label("Returning to Patrol")

func find_target():
	var targets = get_tree().get_nodes_in_group("enemy_targets2")
	print("=== Enemy2 поиск целей ===")
	print("Целей в группе 'enemy_targets2': ", targets.size())
	
	for target in targets:
		print("  Цель: ", target.name)
		print("  Скрипт: ", target.get_script().resource_path if target.get_script() else "нет скрипта")
		print("  Позиция: ", target.global_position)
		print("  Y-координата: ", target.global_position.y)
	
	if targets.size() > 0:
		current_target = targets[0]
		print("Выбрана цель: ", current_target.name, " позиция: ", current_target.global_position)
		update_state_label("Moving to Target")
		is_chasing_player = false

func start_chasing_player():
	if not Global.game_settings["HidePlayer"]:
		current_target = player
		is_chasing_player = true
		was_player_hidden = false
		player_hide_timer = 0.0
		update_state_label("Chasing Player")

func stop_chasing_player():
	find_target()
	update_state_label("Returning to Patrol")

func attack_player():
	if not can_attack_player() or is_shocked:
		return
	
	if player and player.has_method("PlayerDeath"):
		player.look_at_point(global_position)
		player.PlayerDeath(-1)
		apply_shock(3.0)
		await get_tree().create_timer(3).timeout
		global_position = spawnpoint
		print(global_position)

	find_target()

func update_state_label(state: String):
	if state_label:
		state_label.text = state

func _on_vision_area_body_entered(body):
	if body.is_in_group("player"):
		player = body
		if not Global.game_settings["HidePlayer"]:
			start_chasing_player()
		else:
			update_state_label("Player Detected (Hidden)")

func _on_vision_area_body_exited(body):
	if body == player and is_chasing_player:
		lose_player()

func trigger_interaction():
	if Global.game_settings["Item"] == "shotgun":
		apply_shock(120.0)
	elif Global.game_settings["Item"] == "NailGun" and Global.game_settings["nails_cartridge"] > 0:
		var distance_to_player = global_position.distance_to(player.global_position)
		var shock_duration = max(10.0 - distance_to_player, 1.0)
		print(shock_duration)
		apply_shock(shock_duration)
		$nail.play()
		player.UpdateCartridge("NailGun")
	elif Global.game_settings["Item"] == "taser" and Global.game_settings["shock_cartridge"] > 0:
		apply_shock(60)
		start_shock_animation()
		$shock.play()
		player.AnimationPlayPlayer("KillEnemy")
		player.UpdateCartridge("taser")

func _on_mouse_entered() -> void:
	pass

func _on_mouse_exited() -> void:
	pass

func apply_shock(duration: float):
	if is_shocked:
		return
	is_shocked = true
	update_state_label("Shocked!")
	stop_shock_animation()
	velocity = Vector3.ZERO
	sprite_3d.play("shock")
	shock_timer.start(duration)

var shock_tween: Tween

func start_shock_animation():
	var original_position = global_position
	if shock_tween:
		shock_tween.kill()
	shock_tween = create_tween()
	shock_tween.set_loops()
	var shake_intensity = 0.1  # Интенсивность тряски
	var shake_duration = 0.05  # Длительность каждого колебания
	var animation_duration = 2.0
	var iterations = int(animation_duration / (shake_duration * 2))
	for i in range(iterations):
		var random_offset = Vector3(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity * 0.5, shake_intensity * 0.5),
			randf_range(-shake_intensity, shake_intensity)
		)
		shock_tween.tween_property(self, "global_position", original_position + random_offset, shake_duration)
		shock_tween.tween_property(self, "global_position", original_position, shake_duration)
	if sprite_3d:
		sprite_3d.modulate = Color(0.5, 0.8, 1.0)  # Синеватый оттенок
	shock_animation_timer.start(animation_duration)

func stop_shock_animation():
	if shock_tween:
		shock_tween.kill()
		shock_tween = null
	if sprite_3d:
		sprite_3d.modulate = Color.WHITE

func _on_shock_animation_timer_timeout() -> void:
	stop_shock_animation()

func _on_shock_timer_timeout() -> void:
	is_shocked = false
	stop_shock_animation()
	update_sprite_animation()
	if is_chasing_player:
		update_state_label("Chasing Player")
	else:
		update_state_label("Patrolling")
