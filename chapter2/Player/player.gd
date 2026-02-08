extends CharacterBody3D
 
@onready var head = $head
@onready var cam = $head/Camera3D
@onready var stamina_bar = $head/Camera3D/staminaProgressBar
@onready var blood_overlay = $head/Camera3D/blood1
@onready var footstep_player = $FootstepPlayer
@onready var footstep_player2 = $FootstepPlayer2
@onready var footstep_player3 = $FootstepPlayer3
@onready var crosshair = $head/Camera3D/crosshair
@onready var hand_position = $hand_position
@onready var hand_target: Marker3D = $head/Camera3D/HandTarget
@onready var raycast: RayCast3D = $head/Camera3D/RayCast
@onready var bullet_spawn_point = $head/Camera3D/BulletSpawn

var interaction_manager: InteractionManager

var accel = 6
var SPEED = 5.0
var base_speed = 5.0
var crouched = false
var input_dir = Vector3(0,0,0)
var direction = Vector3() 
var sens = 0.005
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var is_walking = false
var footstep_timer = 0.0
var footstep_delay = 0.5

var standing_height = 1.85
var crouching_height = 1.0
var standing_collision_height = 1.143
var crouching_collision_height = 0.66
var standing_collision_scale = 1.0
var crouching_collision_scale = 0.4

var was_under_obstacle = false

var movement_enabled: bool = true

var cheat_f3: bool = false

# Динамика камеры
var camera_tilt_amount = 1.5  # градусы наклона при движении
var camera_tilt_speed = 8.0   # скорость наклона
var current_tilt = 0.0        # текущий наклон

# Дыхание
var breathing_amplitude = 0.05  # амплитуда движения при дыхании
var breathing_frequency = 0.5   # частота дыхания
var breathing_time = 0.0
var base_camera_position = Vector3()

# FOV эффекты
var base_fov: float = 75.0  # базовое значение FOV
var running_fov: float = 80.0  # FOV при беге
var fov_transition_speed: float = 8.0  # скорость изменения FOV
var current_fov: float = base_fov

# энергия
var is_running = false
var stamina = 100.0
var max_stamina = 100.0
var stamina_depletion_rate = 50.0  # Скорость расходования стамины в секунду
var stamina_regen_rate = 20.0      # Скорость восстановления стамины в секунду
var can_regenerate = true
var regen_delay = 1  # Задержка перед восстановлением после бега
var regen_timer = 0.0

var is_paused = false
var is_terminal = false

#прыжок
var jump_velocity = 4.5
var is_jumping = false
var jump_cooldown = 0.2
var jump_cooldown_timer = 0.0

var vertical_movement_speed = 5.0 # Скорость движения вверх/вниз при отключенной гравитации

#полёт
var is_floating: bool = false
var float_start_height: float = 0.0
var float_target_height: float = 0.0
var float_speed: float = 3.0 # скорость подъема/спуска при парении

# инерция руки
var hand_follow_speed = 15.0  # Скорость следования руки (чем больше, тем быстрее)
var hand_rotation_speed = 15.0  # Скорость поворота руки
var max_hand_offset = Vector3(0.1, 0.1, 0.1)

# стрельба
var bullet_scene = preload("res://chapter2/item/Taser_projectile/Taser_projectile.tscn")
var is_reloading = false
var fire_rate = 0.2  # задержка между выстрелами
var last_fire_time = 0.0
var bullet_speed = 50.0  # скорость пули
var stamina_cost_per_shot = 8.0  # Стоимость стамины за выстрел
var min_stamina_to_shoot = 5.0 

func _update_hand_position(delta):
	if not hand_target or not hand_position:
		return
	var target_position = hand_target.global_position
	var current_position = hand_position.global_position
	var position_diff = target_position - current_position
	var move_amount = position_diff * hand_follow_speed * delta
	hand_position.global_position += move_amount
	var target_rotation = hand_target.global_rotation
	var current_rotation = hand_position.global_rotation
	var rotation_diff = target_rotation - current_rotation
	for i in range(3):
		while rotation_diff[i] > PI:
			rotation_diff[i] -= 2 * PI
		while rotation_diff[i] < -PI:
			rotation_diff[i] += 2 * PI
	var rotation_amount = rotation_diff * hand_rotation_speed * delta
	hand_position.global_rotation += rotation_amount
	if input_dir.length() > 0 and is_on_floor():
		var time = Time.get_ticks_msec() * 0.001
		var move_offset = Vector3(
			sin(time * 5.0) * 0.005,
			cos(time * 3.0) * 0.0025,
			0
		)
		hand_position.position += move_offset

func look_at_point(target_point: Vector3):
	var head_look_point = Vector3(target_point.x, head.global_position.y, target_point.z)
	head.look_at(head_look_point, Vector3.UP)
	cam.rotation.x = 0

func _ready():
	interaction_manager = InteractionManager.new(
		self,
		cam,
		crosshair,
		$head/Camera3D/InteractionProgressBar
	)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	movement_enabled = true
	Global.game_settings["GodMod"] = false
	Global.game_settings["affected_by_gravity"] = true
	base_camera_position = cam.position
	update_stamina_display()
	stamina_bar.visible = false  
	update_gui_visibility()
	if Global.game_settings["gui_settings"]["Autosave"]:
		$save.start()

func PlayerDeath():
	if Global.game_settings["IsDying"]:
		return
	Global.game_settings["IsDying"] = true
	$screem.play()
	throw_camera_out()
	movement_enabled = false
	velocity = Vector3.ZERO
	is_running = false
	$head/Camera3D/UI.visible = false
	$hand_position.visible = false
	await get_tree().create_timer(2.5).timeout
	Global.game_settings["HP"] = 100
	respawn_player()

func shoot():
	if not movement_enabled or Global.game_settings["IsDying"] or not $hand_position/handItem.visible:
		return
	if stamina < min_stamina_to_shoot:
		return
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - last_fire_time < fire_rate:
		return
	stamina = max(0, stamina - stamina_cost_per_shot)
	can_regenerate = false
	regen_timer = 0.0
	update_stamina_display()
	var bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)
	bullet.global_transform = bullet_spawn_point.global_transform
	var shoot_direction = -cam.global_transform.basis.z.normalized()  
	if raycast and raycast.is_colliding():
		var hit_point = raycast.get_collision_point()
		shoot_direction = (hit_point - bullet_spawn_point.global_position).normalized()
	if bullet.has_method("shoot"):
		bullet.shoot(shoot_direction, bullet_speed)
	elif bullet.has_method("apply_central_impulse") and bullet is RigidBody3D:
		bullet.apply_central_impulse(shoot_direction * bullet_speed)
	elif bullet.has_method("set_velocity") and bullet is CharacterBody3D:
		bullet.velocity = shoot_direction * bullet_speed
	last_fire_time = current_time
	$laser_blast.pitch_scale = randf_range(0.9, 1.1)
	$laser_blast.play()
	add_recoil()

func add_recoil():
	var recoil_rotation = Vector2(
		randf_range(-0.5, 0.5),  # случайное смещение по X
		randf_range(1.0, 2.0)    # отдача вверх по Y
	) * 0.01  # множитель для силы отдачи
	cam.rotate_x(recoil_rotation.y)
	head.rotate_y(recoil_rotation.x)
	var camera_x_rotation = cam.rotation.x
	if camera_x_rotation < deg_to_rad(-89) or camera_x_rotation > deg_to_rad(89):
		cam.rotation.x = clamp(camera_x_rotation, deg_to_rad(-89), deg_to_rad(89))

func HP(hp):
	if Global.game_settings["IsDying"]:
		return
	Global.game_settings["HP"] -= hp
	if Global.game_settings["HP"] <= 0:
		PlayerDeath()

func respawn_player():
	save()
	SceneManager.load_scene_with_loading("res://chapter2/rooms/GlobalMain.tscn")

func throw_camera_out():
	var cam_scene = load("res://chapter2/item/cam.tscn")
	var thrown_cam = cam_scene.instantiate()
	get_parent().add_child(thrown_cam)
	thrown_cam.global_position = cam.global_position
	thrown_cam.global_rotation = cam.global_rotation
	var throw_direction = -cam.global_transform.basis.z 
	var throw_force = throw_direction + Vector3.UP * 3.0
	if thrown_cam.has_method("apply_impulse"):
		thrown_cam.apply_impulse(throw_force)
	cam.current = false
	var thrown_camera_node = find_camera_in_node(thrown_cam)
	if thrown_camera_node:
		thrown_camera_node.current = true
	Global.game_settings["ThrownCamera"] = thrown_cam

func find_camera_in_node(node: Node) -> Camera3D:
	if node is Camera3D:
		return node
	for child in node.get_children():
		var camera = find_camera_in_node(child)
		if camera:
			return camera
	return null

func set_movement_enabled(enabled: bool):
	movement_enabled = enabled
	if not enabled:
		velocity.x = 0
		velocity.z = 0

func show_blood_overlay():
	blood_overlay.modulate = Color(1.0, 1.0, 1.0, 1.0)
	blood_overlay.visible = true

func play_blood_animation():
	$AnimationPlayer.play("blood")

func toggle_terminal():
	is_terminal = !is_terminal
	if is_terminal:
		openUI("Terminal")
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		$head/Camera3D/Terminal.visible = false

func update_gui_visibility():
	var gui_settings = Global.game_settings["gui_settings"]
	$head/Camera3D/coordinates.visible = gui_settings["Coords"]
	$head/Camera3D/fps.visible = gui_settings["FPS"]

func _input(event: InputEvent): #повороты мышкой
	if Input.is_action_pressed("UI_click") and not is_terminal and not is_paused:
		shoot()
	if Input.is_action_just_pressed("+1"):
		if $hand_position/handItem.visible:
			$hand_position/handItem.visible = false
		else:
			$hand_position/AnimationPlayer.play("take")
	if Input.is_action_just_pressed("rotate"):
		$hand_position/AnimationPlayer.play("r")
	if Input.is_action_just_pressed("UI_focus_next"):
		handle_ui_action("Inventory")
	if Input.is_action_just_pressed("+q"):
		handle_ui_action("AIship")
	if Input.is_action_just_pressed("ui_cancel"):
		handle_ui_action("pause")
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and not Global.game_settings["IsDying"]:
		if event is InputEventMouseMotion:
			head.rotate_y(-event.relative.x * sens)
			var vertical_rotation = -event.relative.y * sens
			var new_camera_rotation = cam.rotation.x + vertical_rotation
			if new_camera_rotation < deg_to_rad(-89) or new_camera_rotation > deg_to_rad(89):
				vertical_rotation = 0
			cam.rotate_x(vertical_rotation)
	if event.is_action_pressed("UI_fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	if Input.is_action_just_pressed("+crouch") and Global.game_settings["affected_by_gravity"]:
		if crouched:
			if Global.game_settings["CanStandUp"]:
				crouched = false
		else:
			crouched = !crouched  
		update_running_speed()
	if Input.is_action_just_pressed("+f1"):
		var handVisible = !$hand_position/handItem.visible
		$head/Camera3D/UI.visible = handVisible
		if handVisible:
			$hand_position/AnimationPlayer.play("take")
		else:
			$hand_position/handItem.visible = false
	if Input.is_action_just_pressed("+~"):
		if !is_paused:
			toggle_terminal()
		else:
			openUI("Pause")
	if not Global.game_settings["IsDying"]:
		interaction_manager.process_interaction_input()

func ghost_cheat():
	cheat_f3 = !cheat_f3
	if cheat_f3:
		crouched = false
		collision_mask = 1
		Global.game_settings["affected_by_gravity"] = false
	else:
		collision_mask = (1 << 2) | (1 << 3) | (1 << 5)
		Global.game_settings["affected_by_gravity"] = true

func _process(delta):
	$head/Camera3D/fps.text = "FPS: %d" % Engine.get_frames_per_second()
	_update_hand_position(delta)
	_update_camera_dynamics(delta)
	_update_fov_effects(delta)
	_update_stamina(delta)
	_update_camera_dynamics(delta)
	_update_fov_effects(delta)
	interaction_manager.update_interaction(delta)

func _update_stamina(delta):
	if is_running and input_dir.length() > 0 and movement_enabled and is_on_floor():
		stamina = max(0, stamina - stamina_depletion_rate * delta)
		can_regenerate = false
		regen_timer = 0.0
		if stamina <= 0:
			is_running = false
			update_running_speed()
	else:
		if not can_regenerate:
			regen_timer += delta
			if regen_timer >= regen_delay:
				can_regenerate = true
		if can_regenerate and stamina < max_stamina:
			stamina = min(max_stamina, stamina + stamina_regen_rate * delta)
	update_stamina_display()

func update_stamina_display():
	stamina_bar.value = stamina
	if stamina < max_stamina or not can_regenerate:
		stamina_bar.visible = true
	else:
		stamina_bar.visible = false
	if stamina > 20:
		stamina_bar.modulate = Color(1.0, 1.0, 1.0, 1.0)
	else:
		stamina_bar.modulate = Color(1.0, 0.26, 0.26, 1.0)

func _update_fov_effects(delta):
	var target_fov = base_fov
	if movement_enabled and input_dir.length() > 0.1:
		var speed_factor = clamp(velocity.length() / SPEED, 0.0, 1.0)
		target_fov = lerp(base_fov, running_fov, speed_factor)
	current_fov = lerp(current_fov, target_fov, fov_transition_speed * delta)
	cam.fov = current_fov

func _update_camera_dynamics(delta):
	var target_tilt = 0.0
	if movement_enabled and input_dir.length() > 0.1:
		target_tilt = -input_dir.x * camera_tilt_amount
	current_tilt = lerp(current_tilt, target_tilt, camera_tilt_speed * delta)
	cam.rotation.z = deg_to_rad(current_tilt)
	if movement_enabled and input_dir.length() < 0.1 and is_on_floor():
		breathing_time += delta * breathing_frequency
		var breathing_offset = sin(breathing_time) * breathing_amplitude
		cam.position.y = base_camera_position.y + breathing_offset
	else:
		cam.position.y = lerp(cam.position.y, base_camera_position.y, 5.0 * delta)
		if input_dir.length() > 0.1:
			breathing_time = 0.0

func message(Mtext):
	$AnimationPlayer.stop()
	$head/Camera3D/message.text = Mtext
	$AnimationPlayer.play("message")

func _physics_process(delta):
	$head/Camera3D/UI/HP/Label.text = str(int(Global.game_settings["HP"]))
	$head/Camera3D/coordinates.text = "%03d:%03d:%03d" % [global_position.x, global_position.y, global_position.z]
	if not Global.game_settings["affected_by_gravity"]:
		is_floating = false
	if Global.game_settings["affected_by_gravity"]:
		if Input.is_action_just_pressed("+space") and is_on_floor() and Global.game_settings["can_jump"] and movement_enabled and !crouched:
			if jump_cooldown_timer <= 0:
				velocity.y = jump_velocity
				is_jumping = true
				jump_cooldown_timer = jump_cooldown
		if Global.game_settings["FloatHeight"] > 0:
			if Input.is_action_pressed("+space") and not is_on_floor() and movement_enabled and not crouched:
				if not is_floating:
					is_floating = true
					float_start_height = global_position.y
					float_target_height = float_start_height + Global.game_settings["FloatHeight"]
					velocity.y = 0
				else:
					if global_position.y < float_target_height:
						velocity.y = float_speed
					else:
						velocity.y = 0
			if Input.is_action_just_released("+space") and is_floating:
				is_floating = false
			if is_on_floor():
				is_floating = false
		if jump_cooldown_timer > 0:
			jump_cooldown_timer -= delta
		if is_on_floor():
			is_jumping = false
		if not is_on_floor() and not is_floating:
			velocity.y -= gravity * delta
	else:
		handle_flight_movement(delta)
	if Input.is_action_pressed("+shift") and stamina > 0 and input_dir.length() > 0 and movement_enabled and not crouched:
		if not is_running:
			is_running = true
			update_running_speed()
	else:
		if is_running:
			is_running = false
			update_running_speed()
	if Global.game_settings["affected_by_gravity"] and is_on_floor() and input_dir.length() > 0:
		if not is_walking:
			is_walking = true
			footstep_timer = 0
		
		footstep_timer += delta
		if footstep_timer >= footstep_delay:
			play_footstep()
			footstep_timer = 0
	else:
		is_walking = false
	if crouched:
		SPEED = 2.5
		$CollisionShape3D.scale.y = lerp($CollisionShape3D.scale.y,0.4,0.4)
		$CollisionShape3D.position.y = lerp($CollisionShape3D.position.y, 0.66,0.4)
		head.position.y = lerp(head.position.y, 1.0, 0.3)
	else:
		$CollisionShape3D.scale.y = lerp($CollisionShape3D.scale.y, 1.0 ,0.4)
		$CollisionShape3D.position.y = lerp($CollisionShape3D.position.y, 1.143,0.4)
		head.position.y = lerp(head.position.y, 1.85 , 0.3)
	if Global.game_settings["affected_by_gravity"]:
		input_dir = Input.get_vector("+a", "+d", "+w", "+s")
		direction = ($head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if movement_enabled: 
			velocity.x = lerp(velocity.x ,direction.x * SPEED, accel * delta)
			velocity.z = lerp(velocity.z ,direction.z * SPEED, accel * delta)
	move_and_slide()
	interaction_manager.check_interactable()

func force_stand_up():
	if crouched:
		crouched = false
		update_running_speed()

func handle_flight_movement(delta):
	input_dir = Input.get_vector("+a", "+d", "+w", "+s")
	var cam_basis = cam.global_transform.basis
	var flight_direction = Vector3.ZERO
	if input_dir.length() > 0:
		var forward = cam_basis.z  
		var right = cam_basis.x    
		flight_direction = (forward * input_dir.y) + (right * input_dir.x)
		flight_direction = flight_direction.normalized()
	if movement_enabled and flight_direction.length() > 0:
		var target_velocity = flight_direction * float(SPEED)
		velocity.x = lerp(velocity.x, target_velocity.x, accel * delta)
		velocity.y = lerp(velocity.y, target_velocity.y, accel * delta)
		velocity.z = lerp(velocity.z, target_velocity.z, accel * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, accel * delta)
		velocity.y = lerp(velocity.y, 0.0, accel * delta)
		velocity.z = lerp(velocity.z, 0.0, accel * delta)

func update_running_speed():
	if is_running and stamina > 0:
		SPEED = 8  # Скорость бега
		footstep_delay = 0.35  # Более частые шаги при беге
	else:
		SPEED = base_speed
		footstep_delay = 0.5   # Обычная частота шагов

func AnimationPlayPlayer(Anim):
	if not is_instance_valid(self) or not is_inside_tree():
		return
	var anim_player = $AnimationPlayer
	if anim_player and anim_player.has_animation(Anim):
		anim_player.play(Anim)
	else:
		push_error("AnimationPlayer или анимация не найдены: " + str(Anim))

func play_footstep():
	if movement_enabled:
		if Global.game_settings["step"] == 1:
			footstep_player.pitch_scale = randf_range(0.9, 1.1)
			footstep_player.play()
		elif Global.game_settings["step"] == 2:
			footstep_player2.pitch_scale = randf_range(0.9, 1.1)
			footstep_player2.play()
		else:
			footstep_player3.pitch_scale = randf_range(0.9, 1.1)
			footstep_player3.play()

func _on_end_exit_pressed() -> void:
	SceneManager.load_scene_with_loading("res://chapter2/rooms/main.tscn")
	
func save():
	Global.save(Global.game_settings["word"])

func _on_save_timeout() -> void:
	save()

func handle_ui_action(ui_name: String) -> void:
	var has_ui_nodes = cam.get_tree().get_nodes_in_group("UI").size()
	if !is_terminal and has_ui_nodes == 0:
		openUI(ui_name)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		for child in cam.get_children():
			if child.is_in_group("UI"):
				child.queue_free()

func openUI(nameUI):
	var path = "head/Camera3D/" + nameUI
	var node = get_node_or_null(path)
	if not node:
		var ui_scene_path = "res://UI/" + nameUI + "/" + nameUI + ".tscn"
		if ResourceLoader.exists(ui_scene_path):
			var ui_scene = load(ui_scene_path)
			node = ui_scene.instantiate()
			node.name = nameUI
			get_node("head/Camera3D").add_child(node)
			node.add_to_group("UI")
	node.visible = true
	$beep.play()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	update_gui_visibility()
	
func open_inventory(inventory_data: String, label_text: String):
	var node_name = "Inventory"
	var path = "head/Camera3D/" + node_name
	var node = get_node_or_null(path)
	if not node:
		var ui_scene_path = "res://UI/Inventory/Inventory.tscn"
		if ResourceLoader.exists(ui_scene_path):
			var ui_scene = load(ui_scene_path)
			node = ui_scene.instantiate()
			node.name = node_name
			node.set("inventory2", inventory_data)
			node.set("Label2", label_text)
			get_node("head/Camera3D").add_child(node)
			node.add_to_group("UI")
	node.visible = true
	$beep.play()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	update_gui_visibility()
	
func warning(text):
	if $head/Camera3D/label.visible == false:
		$head/Camera3D/label.text = text
		$head/Camera3D/label.visible = true
		$head/Camera3D/warning.play("warning")
		await get_tree().create_timer(5).timeout
		$head/Camera3D/warning.play("warning", -1, -1.0, true)
		$head/Camera3D/label.visible = false
