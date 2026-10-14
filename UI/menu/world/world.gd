extends Node2D

var select_world = "world_1"

@onready var panel = $Panel
@onready var world_setting = $Panel/worldSetting
@onready var world_setting_vbox = $Panel/worldSetting/VBoxContainer
@onready var confirmation_dialog = $confirmation
@onready var stage_label = $Panel/worldSetting/VBoxContainer/stage
@onready var delete_button = $Panel/worldSetting/VBoxContainer/delete
@onready var load_button = $Panel/worldSetting/VBoxContainer/load

func _on_label_button_pressed(id: String) -> void:
	match id:
		"BACK":
			visible = false
			world_setting.visible = false
			get_parent().get_node("menu").visible = true
			select_world = "world_1"
		"world_1", "world_2", "world_3", "world_4", "world_5":
			world_setting.visible = true
			select_world = id
			stage_label.text = "level: " + str(Global.get(select_world)["level"])
		"delete":
			confirmation_dialog.visible = true
			panel.visible = false
			world_setting.visible = false
		"CANCEL":
			confirmation_dialog.visible = false
			panel.visible = true
		"DELETE":
			confirmation_dialog.visible = false
			panel.visible = true
			Global.delete_world_save(int(select_world[-1]))
		"load":
			Global.save(int(select_world[-1]))
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
