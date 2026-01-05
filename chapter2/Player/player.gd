extends CharacterBody3D
 
@onready var head = $head
@onready var cam = $head/Camera3D
@onready var stamina_bar = $head/Camera3D/staminaProgressBar
@onready var time_label = $head/Camera3D/TimeLabel
@onready var blood_overlay = $head/Camera3D/blood1
@onready var footstep_player = $FootstepPlayer
@onready var footstep_player2 = $FootstepPlayer2
@onready var crosshair = $head/Camera3D/crosshair
@onready var hand_sprite = $head/Camera3D/hand_position/Sprite3D
@onready var hand_target: Marker3D = $head/Camera3D/HandTarget
@onready var raycast: RayCast3D = $head/Camera3D/RayCast

var interaction_manager: InteractionManager

var accel = 6
var SPEED = 5.0
var base_speed = 5.0
var crouched = false
var input_dir = Vector3(0,0,0)
var direction = Vector3() 
var sens = 0.005
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * 2
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

var time_elapsed: float = 0.0
var is_runningTime: bool = false

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

# бег
var is_running = false
var stamina = 100.0
var max_stamina = 100.0
var stamina_depletion_rate = 50.0  # Скорость расходования стамины в секунду
var stamina_regen_rate = 20.0      # Скорость восстановления стамины в секунду
var can_regenerate = true
var regen_delay = 3  # Задержка перед восстановлением после бега
var regen_timer = 0.0

var is_paused = false
var is_terminal = false

#прыжок
var jump_velocity = 4.5
var is_jumping = false
var jump_cooldown = 0.2
var jump_cooldown_timer = 0.0

var vertical_movement_speed = 5.0 # Скорость движения вверх/вниз при отключенной гравитации

#стройка
var grid_size = 0.25
var ghost_block: Node3D = null
var objects = {
	"light": preload("res://chapter2/Objects/light.tscn"),
	"foundation": preload("res://chapter2/Objects/foundation.tscn")
}
var current_build_object: String = ""

#полёт
var is_floating: bool = false
var float_start_height: float = 0.0
var float_target_height: float = 0.0
var float_speed: float = 3.0 # скорость подъема/спуска при парении

var stepGrass = false

func building(_delta):
	if not ghost_block or current_build_object == "":
		return
	var snap_pos: Vector3 = snap_to_grid(hand_target.global_position, grid_size)
	ghost_block.global_position = lerp(ghost_block.global_position, snap_pos, 0.1)
	if Input.is_action_just_pressed("rotate"):
		ghost_block.rotation.y += deg_to_rad(45)
	if Input.is_action_just_pressed("UI_click") and ghost_block.can_place:
		var block_instance = objects[current_build_object].instantiate()
		get_parent().add_child(block_instance)
		block_instance.place()
		block_instance.global_transform.origin = snap_to_grid(ghost_block.global_transform.origin, grid_size)
		block_instance.global_rotation = ghost_block.global_rotation

func snap_to_grid(input_position: Vector3, grid_snap: float) -> Vector3:
	var x = round(input_position.x / grid_snap) * grid_snap
	var y = round(input_position.y / grid_snap) * grid_snap
	var z = round(input_position.z / grid_snap) * grid_snap
	return Vector3(x,y,z)

func spawn_ghost_block(object_type: String):
	if current_build_object == object_type and ghost_block:
		return
	if ghost_block:
		ghost_block.queue_free()
		ghost_block = null
	if objects.has(object_type):
		current_build_object = object_type
		ghost_block = objects[object_type].instantiate()
		get_parent().add_child(ghost_block)
		ghost_block.global_position = self.global_position
		ghost_block.global_position.y -= 1.0
	else:
		current_build_object = ""

func stop_building():
	if ghost_block:
		ghost_block.queue_free()
		ghost_block = null
	current_build_object = ""

func look_at_point(target_point: Vector3):
	var head_look_point = Vector3(target_point.x, head.global_position.y, target_point.z)
	head.look_at(head_look_point, Vector3.UP)
	cam.rotation.x = 0

func _ready():
	interaction_manager = InteractionManager.new(
		self,
		cam,
		crosshair,
		$head/Camera3D/InteractionProgressBar,
		hand_sprite
	)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	movement_enabled = true
	Global.game_settings["Item"] = ""
	Global.game_settings["GodMod"] = false
	Global.game_settings["affected_by_gravity"] = true
	Global.game_settings["nails_cartridge"] = 8
	Global.game_settings["shock_cartridge"] = 2
	base_camera_position = cam.position
	update_stamina_display()
	stamina_bar.visible = false  
	$open.play()
	if Global.game_settings["ModHard"]:
		DarkHardMod(true)
	update_gui_visibility()

func DarkHardMod(mod):
	if mod:
		$head/Camera3D/SpotLight3D.visible = false
	else:
		$head/Camera3D/SpotLight3D.visible = true

func UpdateCartridge(itemShot):
	if itemShot == "NailGun":
		Global.game_settings["nails_cartridge"] -= 1
		$head/Camera3D/shoot2.text = "%01d/8" % [Global.game_settings["nails_cartridge"]]
		print(Global.game_settings["nails_cartridge"])
	if itemShot == "taser":
		Global.game_settings["shock_cartridge"] -= 1
		$head/Camera3D/shoot2.text = "%01d/2" % [Global.game_settings["shock_cartridge"]]
		print(Global.game_settings["shock_cartridge"])

func PlayerDeath(Hp):
	if Global.game_settings["IsDying"]:
		return
	Global.game_settings["IsDying"] = true
	Global.game_settings["HP"] += Hp
	print("HP: ", Global.game_settings["HP"])
	if Global.game_settings["HP"] < 5:
		screem()
		throw_camera_out()
		drop_item()
		movement_enabled = false
		velocity = Vector3.ZERO
		is_running = false
		await get_tree().create_timer(2.5).timeout
	respawn_player()

func screem():
	$screem.pitch_scale = randf_range(0.4, 0.6)
	$screem.play()

func respawn_player():
	Global.game_settings["IsDying"] = false
	if Global.game_settings.has("ThrownCamera") and is_instance_valid(Global.game_settings["ThrownCamera"]):
		Global.game_settings["ThrownCamera"].queue_free()
		Global.game_settings["ThrownCamera"] = null
	cam.current = true
	velocity = Vector3.ZERO
	if Global.game_settings["affected_by_gravity"]:
		velocity.y = 0
	if Global.game_settings["HP"] <= 1:
		global_position = Vector3(-22.0, -6.24, -15.0)
	else:
		global_position = Vector3(2.599, 0.656, 2.599)
	is_floating = false  
	movement_enabled = false
	stamina = max_stamina
	is_running = false
	SPEED = base_speed
	update_running_speed()
	update_stamina_display()
	$head/Camera3D/Time.visible = true
	$head/Camera3D/label.visible = false
	time_label.visible = true
	blood_overlay.visible = false
	stepGrass = false
	if Global.game_settings["HP"] == 4:
		time_label.text = "01:30"
	elif Global.game_settings["HP"] == 3:
		time_label.text = "02:00"
		SPEED = 4.0
	elif Global.game_settings["HP"] == 2:
		time_label.text = "03:30"
		$head/Camera3D/blood2.visible = true
	elif Global.game_settings["HP"] == 1:
		time_label.text = "05:00\nlast try"
		SPEED = 3.0
	elif Global.game_settings["HP"] <= 0:
		time_label.text = "06:00"
	update_running_speed()
	$AnimationPlayer.play("TimeHP")
	$tick.play()
	if Global.game_settings["HP"] <= 0:
		Global.game_settings["ModHard"] = false
		if Global.game_settings["HP"] == 0:
			if get_tree().root.has_node("GlobalMain/NavigationRegion3D2/basement/cutscene/Camera3D"):
				get_node("/root/GlobalMain/NavigationRegion3D2/basement/cutscene/Camera3D").current = true
				await get_tree().create_timer(1.0).timeout
				get_node("/root/GlobalMain/NavigationRegion3D2/basement/cutscene/AnimationPlayer").play("cutscene")
				await get_tree().create_timer(4.25).timeout
				$head/Camera3D/TheEND.visible = true
				$head/Camera3D/TheEND2.visible = true
				stopSpreedrun()
				SpreedrunMod(true)
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			SceneManager.load_scene_with_loading("res://chapter2/rooms/main.tscn")
		return
	await get_tree().create_timer(3.0).timeout
	$tick.stop()
	$head/Camera3D/Time.visible = false
	time_label.visible = false
	movement_enabled = true

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

func SpreedrunMod(mod):
	$head/Camera3D/Timespeedrun.visible = mod

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

func toggle_pause():
	is_paused = !is_paused
	if is_paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		$head/Camera3D/Pause.visible = true
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		$head/Camera3D/Pause.visible = false
		update_gui_visibility()

func toggle_terminal():
	is_terminal = !is_terminal
	if is_terminal:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		$head/Camera3D/Terminal.visible = true
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		$head/Camera3D/Terminal.visible = false

func update_gui_visibility():
	var gui_settings = Global.game_settings["gui_settings"]
	$head/Camera3D/coordinates.visible = gui_settings["coordinates"]
	$head/Camera3D/fps.visible = gui_settings["fps"]
	SpreedrunMod(gui_settings["timer"])

func _input(event: InputEvent): #повороты мышкой
	if Input.is_action_just_pressed("ui_cancel"):
		if !is_terminal:
			toggle_pause()
		else:
			toggle_terminal()
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and not Global.game_settings["IsDying"]:
		if event is InputEventMouseMotion:
			head.rotate_y(-event.relative.x * sens)
			var vertical_rotation = -event.relative.y * sens
			var new_camera_rotation = cam.rotation.x + vertical_rotation
			if new_camera_rotation < deg_to_rad(-89) or new_camera_rotation > deg_to_rad(89):
				vertical_rotation = 0
			cam.rotate_x(vertical_rotation)
	if Input.is_action_just_pressed("+drop") and Global.game_settings["Item"] != "":
		drop_item()
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
		if !is_paused:
			toggle_terminal()
		else:
			toggle_pause()
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
	if is_runningTime:
		time_elapsed += delta
		update_textSpreedrun()
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

func drop_item():
	if Global.game_settings["Item"] == "" or !Global.game_settings["CanThrowItem"]:
		return
	var item_scene = load("res://chapter2/item/item.tscn")
	var new_item = item_scene.instantiate()
	var texture_path = "res://chapter2/assets/items/%s.png" % Global.game_settings["Item"]
	print(texture_path)
	new_item.item_texture = load(texture_path)
	get_parent().add_child(new_item)
	new_item.global_position = global_position + Vector3(0, 0.5, 0)
	var throw_force = cam.global_transform.basis.z * -3
	new_item.apply_impulse(throw_force)
	Global.game_settings["Item"] = ""
	hand_sprite.texture = null
	$head/Camera3D/shoot.visible = false
	$head/Camera3D/shoot2.visible = false

func clear_item():
	Global.game_settings["Item"] = ""
	hand_sprite.texture = null

func update_textSpreedrun():
	var minutes = int(time_elapsed / 60)
	var seconds = int(time_elapsed) % 60
	var milliseconds = int((time_elapsed - int(time_elapsed)) * 1000)
	$head/Camera3D/Timespeedrun.text = "Timer: %02d:%02d.%03d" % [minutes, seconds, milliseconds]

func startSpreedrun():
	is_runningTime = true

func stopSpreedrun():
	is_runningTime = false

func message(Mtext):
	$AnimationPlayer.stop()
	$head/Camera3D/message.text = Mtext
	$AnimationPlayer.play("message")

func _physics_process(delta):
	$head/Camera3D/coordinates.text = "%03d:%03d:%03d" % [global_position.x, global_position.y, global_position.z]
	if not Global.game_settings["affected_by_gravity"]:
		is_floating = false
	if ghost_block and current_build_object != "":
		building(delta)
	elif raycast.is_colliding():
		if Input.is_action_just_pressed("+f3"):
			if raycast.get_collider().is_in_group("Object"):
				raycast.get_collider().destroy()
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
	var move_direction = Vector3.ZERO
	if input_dir.length() > 0:
		var forward = cam_basis.z  
		var right = cam_basis.x    
		move_direction = (forward * input_dir.y) + (right * input_dir.x)
		move_direction = move_direction.normalized()
	if movement_enabled and move_direction.length() > 0:
		var target_velocity = move_direction * float(SPEED)
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
	if movement_enabled and stepGrass:
		footstep_player2.pitch_scale = randf_range(0.9, 1.1)
		footstep_player2.play()
	else:
		footstep_player.pitch_scale = randf_range(0.9, 1.1)
		footstep_player.play()

func _on_end_exit_pressed() -> void:
	SceneManager.load_scene_with_loading("res://chapter2/rooms/main.tscn")
