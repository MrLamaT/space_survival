extends Area3D

var skip = true
var hovered = ""
var select_world = "world_0"

var world_names = ["Voyager", "Odyssey", "Exodus", "Zenith", "Nadir", "Apex", "Remnant", "Fracture", "Echo", "Void", "Limbo", "Paragon", "Myriad", "Epsilon", "Sigma", "Cinder", "Ember", "Glimmer", "Flicker", "Haven", "Asylum", "Bastion", "Citadel", "Outpost", "Relic", "Artifact", "Omen", "Portent", "Icarus", "Charybdis", "Scylla", "Proteus", "Janus", "Chronos", "Aether", "Umbra", "Penumbra", "Locus", "Nexus", "Focus", "Vector", "Quasar", "Pulsar", "Nebula", "Singularity", "Eventide", "Solstice", "Equinox", "Drifter", "Nomad", "Wayfarer", "Ranger", "Scavenger", "Forerunner", "Pathfinder", "Beacon", "Harbinger", "Vanguard", "Pioneer", "Revenant", "Phantom", "Wraith", "Specter", "Cipher", "Enigma", "Labyrinth", "Mirage", "Horizon", "Infinity", "Eternity", "Genesis", "Exodus", "Legacy", "Ascension", "Descent", "Convergence", "Divergence", "Resonance", "Frequency", "Catalyst"]

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Initialization_names()

func _input(event):
	if event.is_action_pressed("UI_fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	if event.is_action_pressed("ui_cancel"):
		if !skip:
			skip = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			skip_all_animations()
	if event.is_action_pressed("UI_click"):
		if hovered == "PLAY":
			$menu.visible = false
			$world.visible = true
			$beep.play()
		if hovered == "OPTIONS":
			$menu.visible = false
			$options.visible = true
			$beep.play()
		if hovered == "QUIT":
			get_tree().quit()
		if hovered == "BACK":
			$menu.visible = true
			$options.visible = false
			$world.visible = false
			$worldSetting.visible = false
			$beep.play()
			select_world = "world_0"
		if hovered == "Autosave" or hovered == "Coords" or hovered == "FPS":
			Global.game_settings["gui_settings"][hovered] = !Global.game_settings["gui_settings"][hovered]
			var button_node = $options.get_node(hovered)
			if Global.game_settings["gui_settings"][hovered]:
				button_node.text = hovered + " [ON]"
			else:
				button_node.text = hovered + " [OFF]"
			$beep.play()
			Global.save_settings()
		if hovered.begins_with("[NEW GAME "):
			$worldSetting.visible = true
			$beep.play()
			var world_number = hovered[10]
			select_world = "world_" + world_number
			$worldSetting/WorldName.text = Global.get(select_world)["name"]
			if Global.get(select_world)["mode"] == 1:
				$worldSetting/GameMode.text = "mode: creative"
			else:
				$worldSetting/GameMode.text = "mode: survival"
			$worldSetting/stage.text = "stage: " + str(Global.get(select_world)["stage"])
			if Global.get(select_world)["name"].begins_with("[NEW GAME "):
				$worldSetting/WorldName.text = world_names[randi() % world_names.size()]
				$worldSetting/stage.visible = false
				$worldSetting/delete.visible = false
				$worldSetting/load.text = "create"
			else:
				$worldSetting/stage.visible = true
				$worldSetting/delete.visible = true
				$worldSetting/load.text = "load"
		if hovered == "world name":
			$beep.play()
			var world_data = Global.get(select_world)
			$worldSetting/WorldName.text = world_names[randi() % world_names.size()]
			if !world_data["name"].begins_with("[NEW GAME "):
				world_data["name"] = $worldSetting/WorldName.text
				Initialization_names()
		if hovered == "game mode":
			var world_data = Global.get(select_world)
			if world_data["name"].begins_with("[NEW GAME "):
				$beep.play()
				if world_data["mode"] == 0:
					world_data["mode"] = 1
					$worldSetting/GameMode.text = "mode: creative"
				else:
					world_data["mode"] = 0
					$worldSetting/GameMode.text = "mode: survival"
		if hovered == "delete":
			$beep.play()
			var world_data = Global.get(select_world)
			world_data["name"] = "[NEW GAME " + select_world[-1] + "]"
			world_data["mode"] = 0
			world_data["stage"] = 0
			$worldSetting.visible = false
			Initialization_names()
			$beep.play()
		if hovered == "load":
			$beep.play()
			var world_data = Global.get(select_world)
			if world_data["name"].begins_with("[NEW GAME "):
				$worldSetting.visible = false
				world_data["name"] = $worldSetting/WorldName.text
				Initialization_names()

func Initialization_names():
	$world/ButtonText1.text = Global.world_1["name"]
	$world/ButtonText2.text = Global.world_2["name"]
	$world/ButtonText3.text = Global.world_3["name"]
	$world/ButtonText4.text = Global.world_4["name"]
	$world/ButtonText5.text = Global.world_5["name"]

func skip_all_animations():
	$AnimationPlayer.stop()
	if $AnimationPlayer.has_animation("intro"):
		$AnimationPlayer.play("intro")
		$AnimationPlayer.advance($AnimationPlayer.get_animation("intro").length)
	if $AnimationPlayer.has_animation("textIntro"):
		$AnimationPlayer.play("textIntro")
		$AnimationPlayer.advance($AnimationPlayer.get_animation("textIntro").length)
	if $AnimationPlayer.has_animation("Flowy"):
		$AnimationPlayer.play("Flowy")
		$AnimationPlayer.advance($AnimationPlayer.get_animation("Flowy").length)
	$beep.play()
	_on_animation_player_animation_finished("Flowy")

func On():
	$AnimationPlayer.play("intro")
	skip = false

func on_label_hovered(text_value: String) -> void:
	hovered = text_value
	print("Наведено на: ", text_value)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "intro":
		$beep.play()
		$AnimationPlayer.play("textIntro")
	elif anim_name == "textIntro":
		$AnimationPlayer.play("Flowy")
	elif anim_name == "Flowy":
		skip = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
