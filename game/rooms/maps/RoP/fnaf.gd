extends Node3D

var world = Global.get_world(Global.game_settings.word)

func _ready() -> void:
	$Player.gravity = ProjectSettings.get_setting("physics/3d/default_gravity") / 2
	$Panel.visible = false
	Global.game_settings["checkpoint"] = $kill.global_position
	Global.game_settings["min_y"] = -5.0

var door = [true, true, false] # door[0] - левая дверь, door[1] - правая дверь, door[2] - третья дверь

func handle_interaction(object_name: String):
	if energy <= 0:
		return
	match object_name:
		"cam":
			cam(1)
			update_energy_indicators()
		"door1":
			doorStat(0)
		"door2":
			doorStat(1)

var usage = 1
var energy = 100.0

func doorStat(num):
	get_node("NavigationRegion3D/ImpenetrableField" + str(num)).on(!door[num])
	door[num] = !door[num]
	update_usage()

func update_usage():
	usage = 1
	if $Panel.visible:
		usage += 1
	if !door[0]:
		usage += 1
	if !door[1]:  
		usage += 1
	update_energy_indicators()

func update_energy_indicators():
	for i in range(1, 5):
		var indicator_node = get_node("usage/e" + str(i))
		if indicator_node:
			indicator_node.visible = false
	var usage_to_show = clamp(usage, 1, 4)
	for i in range(1, usage_to_show + 1):
		var indicator_node = get_node("usage/e" + str(i))
		if indicator_node:
			indicator_node.visible = true

func cam(num):
	$blip.play()
	if num != 0 and num != 11:
		var camera = get_node("NavigationRegion3D/cam" + str(num))
		if camera:
			camera.current = true
		$Panel/black.visible = false
		$Panel/reload.visible = false
		$Panel.visible = true
		$NavigationRegion3D/floor_ceiling/room1/button.position.y = 0.0
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		update_usage()
	if num == 10:
		$Panel/reload.visible = true
	if num == 11:
		$Panel/black.visible = true
	if num == 0:
		$Player/head/Camera3D.current = true
		$Panel.visible = false
		$NavigationRegion3D/floor_ceiling/room1/button.position.y = 1.7
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		update_usage()

func _on_button_1_pressed() -> void:
	cam(1)

func _on_button_2_pressed() -> void:
	cam(2)

func _on_button_3_pressed() -> void:
	cam(3)

func _on_button_4_pressed() -> void:
	cam(4)

func _on_button_5_pressed() -> void:
	cam(5)

func _on_button_6_pressed() -> void:
	cam(6)

func _on_button_7_pressed() -> void:
	cam(7)

func _on_button_8_pressed() -> void:
	cam(8)

func _on_button_9_pressed() -> void:
	cam(9)

func _on_button_0_pressed() -> void:
	cam(0)

func _on_button_10_pressed() -> void:
	cam(10)

func _on_button_11_pressed() -> void:
	cam(11)

var sec = 0
var ai = 1
var enemy_room = 1
var attackDelay = 3
var AM = 0
var seedTeleport
var phantom = false

const ROUTES = {
	1: [2, 3],      # сцена -> зал, мастерскую
	2: [5, 7, 9],   # зала -> левый проход, правый проход, туалет
	3: [2],         # мастерская -> зал
	4: [6],         # склад -> левая дверь
	5: [4, 6],      # левый проход -> склад, левая дверь
	6: [],          # левая дверь
	7: [8],         # правй проход -> правая дверь
	8: [],          # правая дверь
	9: [5, 7],      # туалет -> правый проход, левый проход
}

func move_destroyercik(num):
	$Panel/ErrorCam.visible = true
	for i in range(1, 10):
		get_node("NavigationRegion3D/destroyercik" + str(i)).visible = false
	enemy_room = num
	if num == 0:
		$NavigationRegion3D/Wave.position.x = 0.0
		return
	get_node("NavigationRegion3D/destroyercik" + str(num)).visible = true

func isLoss(num):
	attackDelay -= 1
	if attackDelay <= 0:
		if door[num]:
			move_destroyercik(0)
		else:
			enemy_room = 1
			attackDelay = 3
			seedTeleport = 1

func _on_timer_timeout() -> void:
	sec += 1
	$Panel/ErrorCam.visible = false
	if phantom:
		$Panel/reload/ProgressBar.value -= 40
		if $Panel/reload/ProgressBar.value <= 700:
			$Panel/warning/AnimationPlayer.play("idel")
		if $Panel/reload/ProgressBar.value <= 0:
			if !door[2]:
				$NavigationRegion3D/ImpenetrableField2.on(true)
				door[2] = true
			$NavigationRegion3D/Wave2.position.x = 0.0
	if sec % 3 == 0:
		seedTeleport = randi_range(1, 20)
		if enemy_room == 6: 
			isLoss(0)
		if enemy_room == 8: 
			isLoss(1)
		if seedTeleport <= ai:
			var routes = ROUTES.get(enemy_room, [])
			if routes.size() > 0:
				var random_room = routes[randi_range(0, routes.size() - 1)]
				move_destroyercik(random_room)
	if sec % 70 == 0:
		AM += 1
		$Time.text = str(AM) + " AM"
		ai += 1
		phantom = true
		if AM == 6:
			$Timer.stop()
			$Panel2/Time.text = "6 AM"
			$Panel2/AnimationPlayer.play("start")
			$Small.play()
			$ambience.stop()
			await get_tree().create_timer(2).timeout
			SceneManager.load_scene_with_loading(Global.level.get(3))
	if energy > 0:
		energy -= 0.12 * usage
		$power.text = "Power left: " + str(int(energy)) + "%"
		if energy <= 0:
			get_node("NavigationRegion3D/ImpenetrableField0").on(true)
			get_node("NavigationRegion3D/ImpenetrableField1").on(true)
			door[0] = true
			door[1] = true
			cam(0)

func _input(_event: InputEvent):
	if Input.is_action_just_pressed("ui_cancel"):
		$Player/head/Camera3D.current = true
		$Panel.visible = false
		$NavigationRegion3D/floor_ceiling/room1/button.position.y = 1.7
		update_usage()

func _on_reload_pressed() -> void:
	if $Panel/reload/ProgressBar.value < 2000 and $Panel/reload/ProgressBar.value > 0:
		$Panel/reload/ProgressBar.value = 2000
	if $Panel/reload/ProgressBar.value >= 500:
			$Panel/warning/AnimationPlayer.stop()
			$Panel/warning/AnimationPlayer.play("RESET")

func _on_kill_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		SceneManager.load_scene_with_loading(Global.level.get(2))

func _on_ambience_finished() -> void:
	if AM < 6:
		$ambience.play()
