extends Node2D

var select_world = "world_0"
var world_names = ["Voyager", "Odyssey", "Exodus", "Zenith", "Nadir", "Apex", "Remnant", "Fracture", "Echo", "Void", "Limbo", "Paragon", "Myriad", "Epsilon", "Sigma", "Cinder", "Ember", "Glimmer", "Flicker", "Haven", "Asylum", "Bastion", "Citadel", "Outpost", "Relic", "Artifact", "Omen", "Portent", "Icarus", "Charybdis", "Scylla", "Proteus", "Janus", "Chronos", "Aether", "Umbra", "Penumbra", "Locus", "Nexus", "Focus", "Vector", "Quasar", "Pulsar", "Nebula", "Singularity", "Eventide", "Solstice", "Equinox", "Drifter", "Nomad", "Wayfarer", "Ranger", "Scavenger", "Forerunner", "Pathfinder", "Beacon", "Harbinger", "Vanguard", "Pioneer", "Revenant", "Phantom", "Wraith", "Specter", "Cipher", "Enigma", "Labyrinth", "Mirage", "Horizon", "Infinity", "Eternity", "Genesis", "Exodus", "Legacy", "Ascension", "Descent", "Convergence", "Divergence", "Resonance", "Frequency", "Catalyst"]

@onready var panel = $Panel
@onready var world_setting = $Panel/worldSetting
@onready var world_setting_vbox = $Panel/worldSetting/VBoxContainer
@onready var confirmation_dialog = $confirmation
@onready var world_name_label = $Panel/worldSetting/VBoxContainer/WorldName
@onready var game_mode_label = $Panel/worldSetting/VBoxContainer/GameMode
@onready var stage_label = $Panel/worldSetting/VBoxContainer/stage
@onready var delete_button = $Panel/worldSetting/VBoxContainer/delete
@onready var load_button = $Panel/worldSetting/VBoxContainer/load

func _ready() -> void:
	Initialization_names()

func _on_label_button_pressed(id: String) -> void:
	match id:
		"BACK":
			visible = false
			world_setting.visible = false
			get_parent().get_node("menu").visible = true
			$beep.play()
			select_world = "world_0"
		"world_1", "world_2", "world_3", "world_4", "world_5":
			world_setting.visible = true
			$beep.play()
			select_world = id
			world_name_label.text = Global.get(select_world)["name"]
			stage_label.text = "level: " + str(Global.get(select_world)["level"])
			if Global.get(select_world)["name"].begins_with("[NEW GAME "):
				world_name_label.text = world_names[randi() % world_names.size()]
				Global.get(select_world)["mode"] = 0
				game_mode_label.text = "mode: survival"
				stage_label.visible = false
				delete_button.visible = false
				load_button.text = "create"
			else:
				if Global.get(select_world)["mode"] == 1:
					game_mode_label.text = "mode: creative"
				elif Global.get(select_world)["mode"] == 2:
					game_mode_label.text = "mode: hardcore"
				else:
					game_mode_label.text = "mode: survival"
				stage_label.visible = true
				delete_button.visible = true
				load_button.text = "load"
		"world name":
			$beep.play()
			var world_data = Global.get(select_world)
			world_name_label.text = world_names[randi() % world_names.size()]
			if !world_data["name"].begins_with("[NEW GAME "):
				world_data["name"] = world_name_label.text
				Initialization_names()
		"game mode":
			var world_data = Global.get(select_world)
			if world_data["name"].begins_with("[NEW GAME "):
				$beep.play()
				if world_data["mode"] == 0:
					world_data["mode"] = 1
					game_mode_label.text = "mode: creative"
				elif world_data["mode"] == 1:
					world_data["mode"] = 2
					game_mode_label.text = "mode: hardcore"
				else:
					world_data["mode"] = 0
					game_mode_label.text = "mode: survival"
		"delete":
			$beep.play()
			confirmation_dialog.visible = true
			panel.visible = false
			world_setting.visible = false
		"CANCEL":
			$beep.play()
			confirmation_dialog.visible = false
			panel.visible = true
		"DELETE":
			$beep.play()
			confirmation_dialog.visible = false
			panel.visible = true
			Global.delete_world_save(int(select_world[-1]))
			Initialization_names()
		"load":
			$beep.play()
			var world_data = Global.get(select_world)
			if world_data["name"].begins_with("[NEW GAME "):
				world_setting.visible = false
				world_data["name"] = world_name_label.text
				Initialization_names()
				Global.save(int(select_world[-1]))
			else:
				var world_index = int(select_world[-1])
				
				if Global.get_world(world_index)["level"] == 0:
					var level_path = Global.level.get(int(Global.get_world(world_index)["level"]))
					if level_path == null:
						level_path = Global.level[1]
					SceneManager.load_scene_with_loading(level_path)
				else:
					SceneManager.load_scene_with_loading("res://UI/planet/planet.tscn")
				Global.game_settings["word"] = world_index
				print(Global.game_settings["word"])

func Initialization_names():
	$Panel/VBoxContainer/ButtonText1.text = Global.world_1["name"]
	$Panel/VBoxContainer/ButtonText2.text = Global.world_2["name"]
	$Panel/VBoxContainer/ButtonText3.text = Global.world_3["name"]
	$Panel/VBoxContainer/ButtonText4.text = Global.world_4["name"]
	$Panel/VBoxContainer/ButtonText5.text = Global.world_5["name"]
