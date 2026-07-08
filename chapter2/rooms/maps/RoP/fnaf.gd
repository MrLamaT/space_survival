extends Node3D

var world = Global.get_world(Global.game_settings.word)

func _ready() -> void:
	var env_scene = preload("res://chapter2/sky/skybox.tscn")
	var env_instance = env_scene.instantiate()
	add_child(env_instance)
	$Player.gravity = ProjectSettings.get_setting("physics/3d/default_gravity") / 2
	Global.game_settings["step"] = 3
	$Panel.visible = false

var door1 = true
var door2 = true

func handle_interaction(object_name: String):
	match object_name:
		"cam":
			$NavigationRegion3D/cam1.current = true
			$Panel.visible = true
			$NavigationRegion3D/floor_ceiling/room1/button.position.y = 0.0
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		"door1":
			$NavigationRegion3D/ImpenetrableField.on(!door1)
			door1 = !door1
		"door2":
			$NavigationRegion3D/ImpenetrableField2.on(!door2)
			door2 = !door2

func get_checkpoint():
	return Vector3(0.0, 0.656, -52.5)

func _on_button_1_pressed() -> void:
	$NavigationRegion3D/cam1.current = true

func _on_button_2_pressed() -> void:
	$NavigationRegion3D/cam2.current = true 

func _on_button_3_pressed() -> void:
	$NavigationRegion3D/cam3.current = true 

func _on_button_4_pressed() -> void:
	$NavigationRegion3D/cam4.current = true

func _on_button_5_pressed() -> void:
	$NavigationRegion3D/cam5.current = true 

func _on_button_6_pressed() -> void:
	$NavigationRegion3D/cam6.current = true

func _on_button_7_pressed() -> void:
	$NavigationRegion3D/cam7.current = true 

func _on_button_8_pressed() -> void:
	$NavigationRegion3D/cam8.current = true 

func _on_button_9_pressed() -> void:
	$NavigationRegion3D/cam9.current = true 

func _on_button_0_pressed() -> void:
	$Player/head/Camera3D.current = true
	$Panel.visible = false
	$NavigationRegion3D/floor_ceiling/room1/button.position.y = 1.7
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

var sec = 0
var ai = 2
var enemy_room = 1
var fatal_error = 3
var AM = 0
func _on_timer_timeout() -> void:
	sec += 1
	if sec % 3 == 0:
		var seedTeleport = randi_range(1, 20)
		if enemy_room == 6: 
			fatal_error -= 1
			if fatal_error <= 0:
				if door1:
					enemy_room = 0
					$NavigationRegion3D/destroyercik6.visible = false
					$NavigationRegion3D/Wave.position.x = 0.0
				else:
					enemy_room = 1
					seedTeleport = 1
		if enemy_room == 8: 
			fatal_error -= 1
			if fatal_error <= 0:
				if door2:
					enemy_room = 0
					$NavigationRegion3D/destroyercik8.visible = false
					$NavigationRegion3D/Wave.position.x = 0.0
				else:
					enemy_room = 1
					seedTeleport = 1
		if seedTeleport <= ai:
			$NavigationRegion3D/destroyercik1.visible = false
			$NavigationRegion3D/destroyercik2.visible = false
			$NavigationRegion3D/destroyercik3.visible = false
			$NavigationRegion3D/destroyercik4.visible = false
			$NavigationRegion3D/destroyercik5.visible = false
			$NavigationRegion3D/destroyercik6.visible = false
			$NavigationRegion3D/destroyercik7.visible = false
			$NavigationRegion3D/destroyercik8.visible = false
			$NavigationRegion3D/destroyercik9.visible = false
			if enemy_room == 1: 
				enemy_room = randi_range(2, 3)
				if enemy_room == 2:
					$NavigationRegion3D/destroyercik2.visible = true
				else:
					$NavigationRegion3D/destroyercik3.visible = true
			elif enemy_room == 3: 
				enemy_room = 2
				$NavigationRegion3D/destroyercik2.visible = true
			elif enemy_room == 2: 
				if randi_range(1, 3) == 1:
					enemy_room = 5
					$NavigationRegion3D/destroyercik5.visible = true
				elif randi_range(1, 2) == 1:
					enemy_room = 7
					$NavigationRegion3D/destroyercik7.visible = true
				else:
					enemy_room = 9
					$NavigationRegion3D/destroyercik9.visible = true
			elif enemy_room == 9: 
				if randi_range(1, 2) == 1:
					enemy_room = 5
					$NavigationRegion3D/destroyercik5.visible = true
				else:
					enemy_room = 7
					$NavigationRegion3D/destroyercik7.visible = true
			elif enemy_room == 5: 
				if randi_range(1, 2) == 1:
					enemy_room = 4
					$NavigationRegion3D/destroyercik4.visible = true
				else:
					enemy_room = 6
					$NavigationRegion3D/destroyercik6.visible = true
			elif enemy_room == 4: 
				enemy_room = 6
				$NavigationRegion3D/destroyercik6.visible = true
			elif enemy_room == 7: 
				enemy_room = 8
				$NavigationRegion3D/destroyercik8.visible = true
	if sec % 90 == 0:
		AM += 1
		$Time.text = str(AM) + " AM"

func _input(_event: InputEvent):
	if Input.is_action_just_pressed("ui_cancel"):
		$Player/head/Camera3D.current = true
		$Panel.visible = false
		$NavigationRegion3D/floor_ceiling/room1/button.position.y = 1.7
