extends Node2D

func handle_card_pressed(type, id):
	match type:
		"gravity":
			match id:
				"terra":
					var player = get_tree().get_first_node_in_group("player")
					player.gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
				"RoP-856":
					var player = get_tree().get_first_node_in_group("player")
					player.gravity = ProjectSettings.get_setting("physics/3d/default_gravity") / 2
		"skybox":
			match id:
				"Void":
					_replace_skybox(preload("res://chapter2/sky/skybox.tscn"))
				"Clear Sky":
					_replace_skybox(preload("res://chapter2/sky/skyboxBlue.tscn"))
				"Toxic Haze":
					_replace_skybox(preload("res://chapter2/sky/skyboxToxic.tscn"))
				"Crimson Dawn":
					_replace_skybox(preload("res://chapter2/sky/skyboxBlood.tscn"))
				"Rust Storm":
					_replace_skybox(preload("res://chapter2/sky/skyboxRust.tscn"))
				"Pale Dawn":
					_replace_skybox(preload("res://chapter2/sky/skyboxPale.tscn"))
				"Dusk":
					_replace_skybox(preload("res://chapter2/sky/skyboxDusk.tscn"))
		"weapon":
			$Panel.visible = false
			$weapon_slot.visible = true
			var hbox = get_node("weapon_slot/HBoxContainer")
			for i in range(8):
				var button = hbox.get_node("Button" + str(i + 1))
				if button and not button.is_connected("pressed", Callable(self, "_on_weapon_slot_selected").bind(i)):
					button.pressed.connect(_on_weapon_slot_selected.bind(i + 1, id))

func _on_weapon_slot_selected(slot_index: int, weapon_name: String) -> void:
	var player = get_tree().get_first_node_in_group("player")
	player.weapon_system.weapon_slots[slot_index] = weapon_name
	player.weapon_system.equip_weapon(player.weapon_system.weapon_slots.get(slot_index, ""))
	print("Оружие ", weapon_name, " установлено в слот ", slot_index)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Global.game_settings["UI"] = false
	queue_free()

func _replace_skybox(new_skybox_scene: PackedScene) -> void:
	var world_environment = get_tree().get_first_node_in_group("skybox")
	if not world_environment:
		return
	var parent = world_environment.get_parent()
	var index = world_environment.get_index()
	world_environment.queue_free()
	var env_instance = new_skybox_scene.instantiate()
	parent.add_child(env_instance)
	parent.move_child(env_instance, index)
