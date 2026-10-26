extends CharacterBody3D
 
@onready var head = $head
@onready var cam = $head/Camera3D
@onready var stamina_bar = $head/Camera3D/UI/stamina/ProgressBar
@onready var energy_bar = $head/Camera3D/UI/energy/ProgressBar
@onready var alt_energy_bar = $head/Camera3D/UI/energy/ProgressBar2
@onready var HP_bar = $head/Camera3D/UI/HP/ProgressBar
@onready var HP_label = $head/Camera3D/UI/HP/ProgressBar/Label
@onready var blood_overlay = $head/Camera3D/blood
@onready var footstep_player = $FootstepPlayer
@onready var footstep_player2 = $FootstepPlayer2
@onready var footstep_player3 = $FootstepPlayer3
@onready var crosshair = $head/Camera3D/crosshair
@onready var hand_position = $hand_position
@onready var hand_target: Marker3D = $head/Camera3D/HandTarget
@onready var ground_ray = $GroundRay

var current_ground_type = "default" # Текущий тип поверхности под ногами

# ==================== СИСТЕМЫ ====================
var interaction_manager: InteractionManager # Менеджер взаимодействий
var weapon_system: WeaponSystem  # Система оружия
var object_holder: ObjectHolderSystem # система перемещения пропов
var health_system: PlayerHealth #система здоровья

var is_shooting: bool = false # Флаг основной стрельбы
var is_alt_shooting: bool = false # Флаг альтернативной стрельбы

# ==================== ЗДОРОВЬЕ И ДВИЖЕНИЕ ====================
var health: float: # Текущее здоровье игрока
	get:
		return health_system.health if health_system else 100.0
	set(value):
		if health_system:
			health_system.health = value 
var accel = 6 # Ускорение движения
var SPEED = 7.0 # Текущая скорость передвижения
var base_speed = 7.0 # Базовая скорость передвижения
var crouched: bool = false  # Флаг приседания
var falling_fast: bool = false # Флаг быстрого падения
var input_dir: Vector2 = Vector2.ZERO # Направление ввода игрока
var direction = Vector3() # Направление движения
var sens = 0.005 # Чувствительность мыши
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var footstep_timer = 0.0 # Таймер между шагами
var footstep_delay = 0.5 # Задержка между шагами

# ==================== ПРИСЕДАНИЕ ====================
var standing_height = 1.85 # Высота головы стоя
var crouching_height = 1.0 # Высота головы при приседании
var standing_collision_height = 1.143 # Высота коллизии стоя
var crouching_collision_height = 0.66 # Высота коллизии при приседании
var standing_collision_scale = 1.0 # Масштаб коллизии стоя
var crouching_collision_scale = 0.4 # Масштаб коллизии при приседании

var was_under_obstacle = false # Флаг нахождения под препятствием

var movement_enabled: bool = true # Флаг возможности движения

# ==================== ДИНАМИКА КАМЕРЫ ====================
var camera_tilt_amount = 1.5  # градусы наклона при движении
var camera_tilt_speed = 16.0   # скорость наклона
var current_tilt = 0.0        # текущий наклон
var thrown_camera: Node3D = null   # Ссылка на выброшенную камеру

# ==================== ДЫХАНИЕ ====================
var breathing_amplitude = 0.05  # амплитуда движения при дыхании
var breathing_frequency = 1.0   # частота дыхания
var breathing_time = 0.0
var base_camera_position = Vector3()

# ==================== FOV ЭФФЕКТЫ ====================
var base_fov: float = 75.0  # базовое значение FOV
var running_fov: float = 80.0  # FOV при беге
var fov_transition_speed: float = 16.0  # скорость изменения FOV
var current_fov: float = base_fov

# ==================== СЛЭМ ====================
var is_slamming: bool = false
var slam_direction: Vector3 = Vector3.ZERO
var slam_speed: float = base_speed * (24.0 / 16.5)
var crouch_walk_speed: float = 2.5
var is_slide_jumping: bool = false
var slide_jump_air_accel: float = 25.0

# ==================== РЫВОК ====================
var is_dashing: bool = false
var dash_direction: Vector3 = Vector3.ZERO
var dash_timer: float = 0.0
var dash_speed: float = base_speed * (49.5 / 16.5)
var dash_duration: float = 0.18
var dash_stamina_cost: float = 30.0

# ==================== СТАМИНА ====================
var stamina = 100.0 # Текущая стамина
var max_stamina = 100.0
var stamina_depletion_rate = 35.0  # Скорость расходования стамины в секунду
var stamina_regen_rate = 25.0      # Скорость восстановления стамины в секунду
var can_regenerate = true
var regen_delay = 0.5  # Задержка перед восстановлением после бега
var regen_timer = 0.0

# ==================== ЭНЕРГИЯ ДЛЯ ОРУЖИЯ ====================
var energy: float = 100.0
var max_energy: float = 100.0
var energy_regen_rate: float = 25.0      # Скорость восстановления энергии в секунду
var can_regenerate_energy: bool = true
var regen_energy_timer: float = 0.0
var regen_energy_delay: float = 0.5      # Задержка перед восстановлением после стрельбы

# ==================== АЛЬТ-ЭНЕРГИЯ ДЛЯ ОРУЖИЯ ====================
var alt_energy: float = 100.0
var max_alt_energy: float = 100.0
var alt_energy_regen_rate: float = 12.5       # Скорость восстановления энергии в секунду
var can_regenerate_alt_energy: bool = true
var regen_alt_energy_timer: float = 0.0
var regen_alt_energy_delay: float = 1.0
var was_alt_energy_full: bool = true

# ==================== ФОНАРИК ====================
var flashlight_enabled: bool = false

var is_paused = false
var escape_held: bool = false

# ==================== ПРЫЖОК ====================
var jump_velocity = 5.0 # Скорость прыжка
var is_jumping = false
var jump_cooldown = 0.2 # Перезарядка прыжка
var jump_cooldown_timer = 0.0
var has_used_double_jump: bool = true # Флаг использования двойного прыжка

var vertical_movement_speed = 5.0 # Скорость движения вверх/вниз при отключенной гравитации

# ==================== ИНЕРЦИЯ РУКИ ====================
var hand_follow_speed = 15.0  # Скорость следования руки (чем больше, тем быстрее)
var hand_rotation_speed = 15.0  # Скорость поворота руки
var max_hand_offset = Vector3(0.1, 0.1, 0.1)

# ==================== СКОЛЬЖЕНИЕ ПО ЛЬДУ ====================
var is_on_ice: bool = false
var ice_friction: float = 1.0  # Коэффициент сохранения скорости (чем меньше, тем быстрее тормозит)
var ice_accel_multiplier: float = 1.0  # Множитель ускорения на льду

# ==================== ЧИТЫ ====================
var GodMod: bool = false
var noclip: bool = false
var infE: bool = false
var infS: bool = false
var spawnPanel: bool = false

var world = Global.get_world(Global.game_settings.word)

# Обновляет позицию и поворот руки, следуя за целевой точкой
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

# Поворачивает голову игрока в сторону указанной точки
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
	Global.game_settings["UI"] = false
	Global.game_settings["GhostMod"] = false
	movement_enabled = true
	Global.game_settings["WeaponProtection"] = false
	Global.game_settings["affected_by_gravity"] = true 
	base_camera_position = cam.position
	stamina_bar.value = stamina
	update_energy_display()
	update_gui_visibility()
	weapon_system = WeaponSystem.new()
	weapon_system.player = self
	weapon_system.hand_position = hand_position
	weapon_system.cam = cam
	add_child(weapon_system)
	object_holder = ObjectHolderSystem.new()
	object_holder.setup(self, cam, head)
	add_child(object_holder)
	health_system = PlayerHealth.new()
	health_system.setup(self)
	add_child(health_system)
	stamina_bar.max_value = max_stamina
	sens = float(Global.game_settings.gui_settings.sensitivity) * 0.0001
	base_fov = clampf(float(Global.game_settings.gui_settings.get("fov", 75.0)), 60.0, 110.0)
	running_fov = minf(base_fov + 5.0, 115.0)
	current_fov = base_fov
	cam.fov = base_fov

# Обрабатывает смерть игрока
func PlayerDeath():
	health_system.player_death()

# Наносит урон игроку
func take_damage(hp):
	health_system.take_damage(hp)

# Применяет отравление к игроку
func apply_poison(damage: float) -> void:
	health_system.apply_poison(damage)

# Возрождает игрока на последнем чекпоинте
func respawn_player():
	health_system.respawn_player()

# Выбрасывает камеру из рук игрока при смерти
func throw_camera_out():
	var cam_scene = load("res://game/item/cam.tscn")
	var thrown_cam = cam_scene.instantiate()
	get_parent().add_child(thrown_cam)
	thrown_cam.global_position = cam.global_position
	thrown_cam.global_rotation = cam.global_rotation
	var throw_direction = -cam.global_transform.basis.z 
	var throw_force = throw_direction + Vector3.UP * 3.0
	if thrown_cam.has_method("apply_impulse"):
		thrown_cam.apply_impulse(throw_force)
	cam.current = false
	thrown_cam.get_node("Camera3D").current = true
	thrown_camera = thrown_cam

# Устанавливает возможность движения игрока
func set_movement_enabled(enabled: bool):
	movement_enabled = enabled
	if not enabled:
		velocity.x = 0
		velocity.z = 0

# Обновляет видимость элементов GUI
func update_gui_visibility():
	var gui_settings = Global.game_settings["gui_settings"]
	$head/Camera3D/UI/coordinates.visible = gui_settings["Coords"]
	$head/Camera3D/UI/fps.visible = gui_settings["FPS"]
	$head/Camera3D/UI/speed.visible = gui_settings["Speed"]

# Обрабатывает ввод игрока (повороты мышкой, стрельба, взаимодействия)
func _input(event: InputEvent):
	if SettingsManager.is_rebinding:
		return
	if event.is_action_released("UI_click"):
		is_shooting = false
	if event.is_action_released("UI_alt_click"):
		is_alt_shooting = false
	if event.is_action_released("ui_cancel"):
		escape_held = false
		return
	if event.is_action_pressed("ui_cancel"):
		if escape_held:
			return
		escape_held = true
		object_holder.release(false)
		handle_ui_action("pause")
		return
	if Global.game_settings["UI"]:
		return
	if event.is_action_pressed("UI_click") and not is_paused:
		is_shooting = true
		weapon_system.shoot(false)
	if event.is_action_pressed("UI_alt_click") and not is_paused:
		is_alt_shooting = true
		weapon_system.shoot(true)
	if event.is_action_pressed("+q"):
		if world["mode"] == 1 or spawnPanel:
			openUI("spawn")
			return
	if Input.is_action_just_pressed("+v") and not Global.game_settings["UI"]:
		if world["mode"] == 1:
			noclip_cheat()
	if Input.is_action_just_pressed("+delete"):
		if world["mode"] == 1:
			var enemies = get_tree().get_nodes_in_group("enemy")
			if enemies.size() > 0:
				for enemy in enemies:
					if enemy.has_method("take_damage"):
						enemy.take_damage(999999)
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and not Global.game_settings["IsDying"]:
		if event is InputEventMouseMotion:
			head.rotate_y(-event.relative.x * sens)
			var vertical_rotation = -event.relative.y * sens
			var new_camera_rotation = cam.rotation.x + vertical_rotation
			if new_camera_rotation < deg_to_rad(-89) or new_camera_rotation > deg_to_rad(89):
				vertical_rotation = 0
			cam.rotate_x(vertical_rotation)
	if Input.is_action_just_pressed("+f"):
		toggle_flashlight()
	if Input.is_action_just_pressed("+f1"):
		$head/Camera3D/UI.visible = !$head/Camera3D/UI.visible
		$head/Camera3D/crosshair.visible = $head/Camera3D/UI.visible
	if not Global.game_settings["IsDying"]:
		interaction_manager.process_interaction_input()

# Переключает фонарик
func toggle_flashlight():
	flashlight_enabled = !flashlight_enabled
	$head/Camera3D/flashlight.visible = flashlight_enabled
	$flashlight.play()

# Переключает режим noclip (полет сквозь стены)
func noclip_cheat():
	noclip = !noclip
	if noclip:
		cancel_dash()
		crouched = false
		collision_mask = 1
		Global.game_settings["affected_by_gravity"] = false
		is_slamming = false
		is_slide_jumping = false
		slam_direction = Vector3.ZERO
		update_running_speed()
	else:
		collision_mask = (1 << 2) | (1 << 3) | (1 << 5)
		Global.game_settings["affected_by_gravity"] = true

# Обрабатывает логику каждый кадр
func _process(delta):
	$head/Camera3D/UI/fps.text = "FPS: %d" % Engine.get_frames_per_second()
	$head/Camera3D/UI/speed.text = "Speed: %.2f" % velocity.length()
	_update_hand_position(delta)
	_update_energy(delta)
	_update_camera_dynamics(delta)
	_update_fov_effects(delta)
	health_system.update(delta)
	interaction_manager.update_interaction(delta)
	if object_holder.is_holding():
		object_holder.update_held_object()

# Обновляет стамину
func _update_stamina(delta):
	if is_dashing:
		can_regenerate = false
		regen_timer = 0.0
		stamina_bar.value = stamina
		return
	if is_slamming:
		can_regenerate = false
		regen_timer = 0.0
		if not infS:
			stamina = maxf(
				0.0,
				stamina - stamina_depletion_rate * delta
			)
			if stamina <= 0.0:
				stop_slam()
	else:
		if not can_regenerate:
			regen_timer += delta
			if regen_timer >= regen_delay:
				can_regenerate = true
		if can_regenerate and stamina < max_stamina:
			stamina = minf(
				max_stamina,
				stamina + stamina_regen_rate * delta
			)
	stamina_bar.value = stamina

# Обновляет энергию и альт-энергию
func _update_energy(delta):
	if not can_regenerate_energy:
		regen_energy_timer += delta
		if regen_energy_timer >= regen_energy_delay:
			can_regenerate_energy = true
	if can_regenerate_energy and energy < max_energy:
		energy = min(max_energy, energy + energy_regen_rate * delta)
	
	if not can_regenerate_alt_energy:
		regen_alt_energy_timer += delta
		if regen_alt_energy_timer >= regen_alt_energy_delay:
			can_regenerate_alt_energy = true
	if can_regenerate_alt_energy and alt_energy < max_alt_energy:
		alt_energy = min(max_alt_energy, alt_energy + alt_energy_regen_rate * delta)
	
	var is_full_now = alt_energy >= max_alt_energy
	if is_full_now and not was_alt_energy_full:
		$charge.play()
	was_alt_energy_full = is_full_now
	
	update_energy_display()

# Обновляет отображение энергии на экране
func update_energy_display():
	if energy_bar:
		energy_bar.value = energy
		if energy > 75:
			energy_bar.modulate = Color("00bfff")
		elif energy > 25:
			energy_bar.modulate = Color("ffff00ff")
		else:
			energy_bar.modulate = Color(1.0, 0.0, 0.0, 1.0)
	if alt_energy_bar:
		alt_energy_bar.value = alt_energy
		if alt_energy == 100:
			alt_energy_bar.modulate = Color("3e0cc7")
		else:
			alt_energy_bar.modulate = Color(1.0, 0.0, 0.0, 1.0)

# Обновляет FOV камеры в зависимости от скорости движения
func _update_fov_effects(delta):
	base_fov = clampf(float(Global.game_settings.gui_settings.get("fov", 75.0)), 60.0, 110.0)
	running_fov = minf(base_fov + 5.0, 115.0)
	var target_fov = base_fov
	if can_move() and input_dir.length() > 0.1:
		var speed_factor = clamp(velocity.length() / SPEED, 0.0, 1.0)
		target_fov = lerp(base_fov, running_fov, speed_factor)
	current_fov = lerp(current_fov, target_fov, fov_transition_speed * delta)
	cam.fov = current_fov

# Обновляет динамику камеры (наклон, дыхание)
func _update_camera_dynamics(delta):
	var target_tilt = 0.0
	if can_move() and input_dir.length() > 0.1:
		target_tilt = -input_dir.x * camera_tilt_amount
	current_tilt = lerp(current_tilt, target_tilt, camera_tilt_speed * delta)
	cam.rotation.z = deg_to_rad(current_tilt)
	if can_move() and input_dir.length() < 0.1 and is_on_floor():
		breathing_time += delta * breathing_frequency
		var breathing_offset = sin(breathing_time) * breathing_amplitude
		cam.position.y = base_camera_position.y + breathing_offset
	else:
		cam.position.y = lerp(cam.position.y, base_camera_position.y, 5.0 * delta)
		if input_dir.length() > 0.1:
			breathing_time = 0.0

# Основная физическая обработка игрока
func _physics_process(delta):
	_update_ui_labels()
	if (
		not can_move()
		or SettingsManager.is_rebinding
		or not Global.game_settings["affected_by_gravity"]
	):
		is_slide_jumping = false
	var dash_active_this_frame: bool = _handle_dash(delta)
	if not dash_active_this_frame:
		_handle_slam()
	_update_stamina(delta)
	update_running_speed()
	if not dash_active_this_frame:
		_handle_gravity_and_jump(delta)
		_handle_movement_input(delta)
	_handle_crouch_animation()
	move_and_slide()
	if is_on_floor():
		is_slide_jumping = false
	if dash_active_this_frame:
		footstep_timer = 0.0
	else:
		_handle_footsteps(delta)
	interaction_manager.check_interactable()
	_handle_shooting()

# Обрабатывает стрельбу
func _handle_shooting():
	if is_shooting and can_move():
		weapon_system.shoot(false)
	if is_alt_shooting and can_move():
		weapon_system.shoot(true)

# Обрабатывает слэм
func _handle_slam() -> void:
	if not can_move() or SettingsManager.is_rebinding:
		if is_slamming:
			stop_slam()
		return
	if not Global.game_settings["affected_by_gravity"]:
		if is_slamming:
			stop_slam()
		return
	var ctrl_held: bool = Input.is_action_pressed("+crouch")
	if is_slamming:
		if not ctrl_held:
			stop_slam()
		elif not is_on_floor():
			is_slide_jumping = true
		return
	if Input.is_action_just_pressed("+crouch"):
		if is_on_floor():
			if stamina > 0.0 or infS:
				start_slam()
			else:
				crouched = true
				update_running_speed()
		else:
			is_slide_jumping = false
			falling_fast = true
			$leg_damage/CollisionShape3D.disabled = false
	if not is_slamming and crouched and not ctrl_held:
		if Global.game_settings["CanStandUp"]:
			crouched = false
			update_running_speed()

# Выбирает горизонтальное направление действия в мировых координатах.
func get_action_direction() -> Vector3:
	var action_input: Vector2 = Input.get_vector("+a", "+d", "+w", "+s")
	if action_input.is_zero_approx():
		action_input = Vector2(0.0, -1.0)

	var local_direction := Vector3(action_input.x, 0.0, action_input.y)
	var action_direction: Vector3 = head.global_transform.basis * local_direction
	action_direction.y = 0.0
	return action_direction.normalized()

func start_slam() -> void:
	if is_slamming:
		return
	if not can_move() or SettingsManager.is_rebinding:
		return
	if not is_on_floor():
		return
	if not Global.game_settings["affected_by_gravity"]:
		return
	if stamina <= 0.0 and not infS:
		return
	slam_direction = get_action_direction()
	if slam_direction.is_zero_approx():
		return
	is_slamming = true
	crouched = true
	can_regenerate = false
	regen_timer = 0.0
	footstep_timer = 0.0
	update_running_speed()

func stop_slam() -> void:
	if not is_slamming:
		return
	is_slamming = false
	slam_direction = Vector3.ZERO
	crouched = not Global.game_settings["CanStandUp"]
	can_regenerate = false
	regen_timer = 0.0
	update_running_speed()
	if is_slide_jumping:
		return
	var horizontal_velocity := Vector2(velocity.x, velocity.z)
	horizontal_velocity = horizontal_velocity.limit_length(SPEED)
	velocity.x = horizontal_velocity.x
	velocity.z = horizontal_velocity.y

# Обрабатывает ввод движения
func _handle_movement_input(delta):
	if is_slide_jumping and can_move():
		input_dir = Input.get_vector("+a", "+d", "+w", "+s")
		if not input_dir.is_zero_approx():
			var wish_direction: Vector3 = (
				head.global_transform.basis
				* Vector3(input_dir.x, 0.0, input_dir.y)
			)
			wish_direction.y = 0.0
			wish_direction = wish_direction.normalized()
			direction = wish_direction
			var horizontal_velocity := Vector2(
				velocity.x,
				velocity.z
			)
			var target_velocity := Vector2(
				wish_direction.x,
				wish_direction.z
			) * slam_speed
			horizontal_velocity = horizontal_velocity.move_toward(
				target_velocity,
				slide_jump_air_accel * delta
			)
			velocity.x = horizontal_velocity.x
			velocity.z = horizontal_velocity.y
		return
	if is_slamming and can_move():
		input_dir = Vector2.ZERO
		direction = slam_direction
		velocity.x = slam_direction.x * slam_speed
		velocity.z = slam_direction.z * slam_speed
		return
	if can_move():
		if Global.game_settings["affected_by_gravity"]:
			input_dir = Input.get_vector("+a", "+d", "+w", "+s")
			direction = ($head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
			if is_on_ice and is_on_floor():
				var current_accel = accel * ice_accel_multiplier
				var target_vel_x = direction.x * SPEED
				var target_vel_z = direction.z * SPEED
				if input_dir.length() == 0:
					velocity.x *= ice_friction
					velocity.z *= ice_friction
				else:
					velocity.x = lerp(velocity.x, target_vel_x, current_accel * delta)
					velocity.z = lerp(velocity.z, target_vel_z, current_accel * delta)
			else:
				velocity.x = lerp(velocity.x, direction.x * SPEED, accel * delta)
				velocity.z = lerp(velocity.z, direction.z * SPEED, accel * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, accel * delta)
		velocity.z = lerp(velocity.z, 0.0, accel * delta)
		if not Global.game_settings["affected_by_gravity"]:
			velocity.y = lerp(velocity.y, 0.0, accel * delta)

# Обрабатывает анимацию приседания
func _handle_crouch_animation():
	if crouched:
		$CollisionShape3D.scale.y = lerp($CollisionShape3D.scale.y, crouching_collision_scale, 0.4)
		$CollisionShape3D.position.y = lerp($CollisionShape3D.position.y, crouching_collision_height, 0.4)
		head.position.y = lerp(head.position.y, crouching_height, 0.3)
	else:
		$CollisionShape3D.scale.y = lerp($CollisionShape3D.scale.y, standing_collision_scale, 0.4)
		$CollisionShape3D.position.y = lerp($CollisionShape3D.position.y, standing_collision_height, 0.4)
		head.position.y = lerp(head.position.y, standing_height, 0.3)

# Обрабатывает звуки шагов
func _handle_footsteps(delta):
	if is_slamming:
		footstep_timer = 0.0
		return
	if Global.game_settings["affected_by_gravity"] and is_on_floor() and input_dir.length() > 0 and can_move():
		footstep_timer += delta
		if footstep_timer >= footstep_delay:
			play_footstep()
			footstep_timer = 0
	else:
		footstep_timer = 0

# Обновляет текстовые метки UI (здоровье, координаты)
func _update_ui_labels():
	HP_label.text = str(int(health))
	HP_bar.value = int(health)
	$head/Camera3D/UI/coordinates.text = "%03d:%03d:%03d" % [global_position.x, global_position.y, global_position.z]

# Обрабатывает гравитацию и прыжки
func _handle_gravity_and_jump(delta):
	if not Global.game_settings["affected_by_gravity"]:
		handle_flight_movement(delta)
		return
	if jump_cooldown_timer > 0.0:
		jump_cooldown_timer = maxf(
			0.0,
			jump_cooldown_timer - delta
		)
	if is_on_floor():
		falling_fast = false
		$leg_damage/CollisionShape3D.disabled = true
		is_jumping = false
	var jump_pressed: bool = Input.is_action_just_pressed("+space")
	var jump_allowed: bool = (
		can_move()
		and not SettingsManager.is_rebinding
		and Global.game_settings["can_jump"]
		and Global.game_settings["CanStandUp"]
	)
	if jump_pressed and jump_allowed:
		if is_on_floor():
			if jump_cooldown_timer <= 0.0:
				if is_slamming:
					is_slide_jumping = true
					velocity.x = slam_direction.x * slam_speed
					velocity.z = slam_direction.z * slam_speed
					crouched = true
				else:
					is_slide_jumping = false
					crouched = false
				velocity.y = jump_velocity
				is_jumping = true
				jump_cooldown_timer = jump_cooldown
				update_running_speed()
		else:
			if not has_used_double_jump:
				velocity.y = jump_velocity
				has_used_double_jump = true
				is_jumping = true
				$spring.play()
	if not is_on_floor():
		if falling_fast and can_move():
			velocity.y -= gravity * delta * 10.0
		else:
			velocity.y -= gravity * delta

# Принудительно заставляет игрока встать
func force_stand_up():
	if is_slamming:
		return
	if not Global.game_settings["CanStandUp"]:
		return
	if crouched:
		crouched = false
		update_running_speed()

# Обрабатывает движение в режиме полета (при отключенной гравитации)
func handle_flight_movement(delta):
	input_dir = Input.get_vector("+a", "+d", "+w", "+s")
	var cam_basis = cam.global_transform.basis
	var flight_direction = Vector3.ZERO
	if input_dir.length() > 0:
		var forward = cam_basis.z  
		var right = cam_basis.x    
		flight_direction = (forward * input_dir.y) + (right * input_dir.x)
		flight_direction = flight_direction.normalized()
	if can_move() and flight_direction.length() > 0:
		var target_velocity = flight_direction * float(SPEED)
		velocity.x = lerp(velocity.x, target_velocity.x, accel * delta)
		velocity.y = lerp(velocity.y, target_velocity.y, accel * delta)
		velocity.z = lerp(velocity.z, target_velocity.z, accel * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, accel * delta)
		velocity.y = lerp(velocity.y, 0.0, accel * delta)
		velocity.z = lerp(velocity.z, 0.0, accel * delta)

# Обновляет скорость бега
func update_running_speed():
	if is_slamming:
		SPEED = slam_speed
	elif crouched:
		SPEED = crouch_walk_speed
	else:
		SPEED = base_speed
	footstep_delay = 0.5

# Воспроизводит звук шага в зависимости от поверхности
func play_footstep():
	var step = detect_ground_material()
	if can_move():
		if step == "default":
			footstep_player.pitch_scale = randf_range(0.9, 1.1)
			footstep_player.play()
		elif step == "grass":
			footstep_player2.pitch_scale = randf_range(0.9, 1.1)
			footstep_player2.play()
		elif step == "metal":
			footstep_player3.pitch_scale = randf_range(0.9, 1.1)
			footstep_player3.play()

# Обрабатывает действие UI (открытие/закрытие)
func handle_ui_action(ui_name: String) -> void:
	var has_ui_nodes = cam.get_tree().get_nodes_in_group("UI").size()
	if has_ui_nodes == 0:
		openUI(ui_name)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		Global.game_settings["UI"] = false
		for child in cam.get_children():
			if child.is_in_group("UI"):
				child.queue_free()

# Открывает указанный UI
func openUI(nameUI):
	is_shooting = false
	is_alt_shooting = false
	var path = "head/Camera3D/" + nameUI
	var node = get_node_or_null(path)
	if not node:
		var ui_scene_path = "res://UI/" + nameUI + "/" + nameUI + ".tscn"
		if ResourceLoader.exists(ui_scene_path):
			var ui_scene = load(ui_scene_path)
			node = ui_scene.instantiate()
			node.name = nameUI
			get_node("head/Camera3D").add_child(node)
			node.z_index = 10
			node.add_to_group("UI")
			Global.game_settings["UI"] = true
	node.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	update_gui_visibility()

# Показывает предупреждение на экране
func warning(text):
	if $head/Camera3D/label.visible == false:
		$head/Camera3D/label.text = text
		$head/Camera3D/label.visible = true
		$head/Camera3D/warning.play("warning")
		await get_tree().create_timer(5).timeout
		$head/Camera3D/warning.play("warning", -1, -1.0, true)
		$head/Camera3D/label.visible = false

# Определяет материал поверхности под ногами
func detect_ground_material():
	if not ground_ray.is_colliding():
		is_on_ice = false
		return "default"
	var collider = ground_ray.get_collider()
	if not collider:
		is_on_ice = false
		return "default"
	if collider.is_in_group("ice"):
		is_on_ice = true
		return "default"
	else:
		is_on_ice = false
	if collider.is_in_group("grass"):
		return "grass"
	elif collider.is_in_group("metal"):
		return "metal"
	return "default"

# Проверяет, может ли игрок двигаться
func can_move() -> bool:
	if not movement_enabled:
		return false
	if Global.game_settings["UI"]:
		return false
	if Global.game_settings["IsDying"]:
		return false
	return true

func start_dash() -> void:
	if is_dashing:
		return
	if not can_move() or SettingsManager.is_rebinding:
		return
	if not Global.game_settings["affected_by_gravity"]:
		return
	if not infS and stamina < dash_stamina_cost:
		return
	dash_direction = get_action_direction()
	if dash_direction.is_zero_approx():
		return
	if not infS:
		stamina = maxf(0.0, stamina - dash_stamina_cost)
	can_regenerate = false
	regen_timer = 0.0
	stamina_bar.value = stamina
	is_slamming = false
	is_slide_jumping = false
	slam_direction = Vector3.ZERO
	falling_fast = false
	$leg_damage/CollisionShape3D.set_deferred("disabled", true)
	is_dashing = true
	dash_timer = dash_duration
	footstep_timer = 0.0
	velocity = dash_direction * dash_speed
	update_running_speed()

func cancel_dash() -> void:
	is_dashing = false
	dash_timer = 0.0
	dash_direction = Vector3.ZERO

func _handle_dash(delta: float) -> bool:
	if (
		not can_move()
		or SettingsManager.is_rebinding
		or not Global.game_settings["affected_by_gravity"]
	):
		cancel_dash()
		return false
	if is_dashing and dash_timer <= 0.0:
		cancel_dash()
	if not is_dashing and Input.is_action_just_pressed("+shift"):
		start_dash()
	if not is_dashing:
		return false
	dash_timer -= delta
	input_dir = Vector2.ZERO
	velocity = dash_direction * dash_speed
	velocity.y = 0.0
	return true
