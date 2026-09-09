extends Node2D

var current_item_id: String = ""

func handle_card_pressed(type, id, color_img):
	match type:
		"gravity":
			Global.game_settings["affected_by_gravity"] = true
			match id:
				"None":
					Global.game_settings["affected_by_gravity"] = false
				"Terra":
					var player = get_tree().get_first_node_in_group("player")
					player.gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
				"Weak":
					var player = get_tree().get_first_node_in_group("player")
					player.gravity = ProjectSettings.get_setting("physics/3d/default_gravity") / 2
				"Supermass":
					var player = get_tree().get_first_node_in_group("player")
					player.gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * 2
		"skybox":
			match id:
				"Void":
					_replace_skybox(preload("res://game/sky/skybox.tscn"))
				"Clear Sky":
					_replace_skybox(preload("res://game/sky/skyboxBlue.tscn"))
				"Toxic Haze":
					_replace_skybox(preload("res://game/sky/skyboxToxic.tscn"))
				"Crimson Dawn":
					_replace_skybox(preload("res://game/sky/skyboxBlood.tscn"))
				"Rust Storm":
					_replace_skybox(preload("res://game/sky/skyboxRust.tscn"))
				"Pale Dawn":
					_replace_skybox(preload("res://game/sky/skyboxPale.tscn"))
				"Dusk":
					_replace_skybox(preload("res://game/sky/skyboxDusk.tscn"))
		"filters":
			var filter = get_tree().get_first_node_in_group("filter")
			if id == "None":
				filter.visible = false
				return
			filter.visible = true
			match id:
				"noir":
					filter.material_override = preload("res://assets/shaders/filter/noir.tres")
				"except orange":
					filter.material_override = preload("res://assets/shaders/filter/noir_orange.tres")
				"VHS":
					filter.material_override = preload("res://assets/shaders/filter/VHS.tres")
				"Fisheye":
					filter.material_override = preload("res://assets/shaders/filter/flisheye.tres")
				"Blur":
					filter.material_override = preload("res://assets/shaders/filter/blur.tres")
				"Shuffle":
					filter.material_override = preload("res://assets/shaders/filter/shuffle.tres")
				"Gamma":
					filter.material_override = preload("res://assets/shaders/filter/gamma.tres")
				"Water":
					filter.material_override = preload("res://assets/shaders/filter/f_water.tres")
		"weapon":
			$Panel.visible = false
			$weapon_slot.visible = true
			var hbox = get_node("weapon_slot/HBoxContainer")
			for i in range(8):
				var button = hbox.get_node("Button" + str(i + 1))
				if button and not button.is_connected("pressed", Callable(self, "_on_weapon_slot_selected").bind(i)):
					button.pressed.connect(_on_weapon_slot_selected.bind(i + 1, id))
		"costumes":
			var world = Global.get_world(Global.game_settings.word)
			world["costumes"] = id
			var hand_nodes = get_tree().get_nodes_in_group("hand")
			for node in hand_nodes:
				node.create_custom_material()
			Global.save(Global.game_settings["word"])
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			Global.game_settings["UI"] = false
			queue_free()
		"item":
			$Panel.visible = false
			$item_slot.visible = true
			current_item_id = id
			_update_item_display()
		"enemies":
			Global.game_settings["summon"]["name"] = id
			$Panel.visible = false
			$Enemy_slot.visible = true
			$Enemy_slot/CheckBox.button_pressed = Global.game_settings["summon"]["boss"]
			if int(Global.game_settings["summon"]["aura"]) > 0:
				$Enemy_slot/LineEdit.text = str(int(Global.game_settings["summon"]["aura"]))
		"props":
			Global.game_settings["summon"]["name"] = id
			get_tree().get_first_node_in_group("player").weapon_system.equip_weapon("Summon")
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			Global.game_settings["UI"] = false
			queue_free()
		"style_block":
			if id == "plank":
				var plank = preload("res://assets/material/plank.tres")
				plank.albedo_color = color_img
			if id == "grass":
				var earth = preload("res://assets/material/earth.tres")
				earth.albedo_color = color_img
			if id == "stone":
				var stone = preload("res://assets/material/stone.tres")
				stone.albedo_color = color_img
			if id == "water":
				var water = preload("res://assets/material/water.tres")
				water.albedo_color = color_img
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			Global.game_settings["UI"] = false
			queue_free()
		"block":
			Global.game_settings["summon_block"]["name"] = id
			get_tree().get_first_node_in_group("player").weapon_system.equip_weapon("Block")
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			Global.game_settings["UI"] = false
			queue_free()
		"maps":
			match id:
				"level list":
					var player = get_tree().get_first_node_in_group("player")
					player.openUI("planet")
					queue_free()
				"unlock levels": 
					var world = Global.get_world(Global.game_settings.word)
					world["level"] = 5
					world["stage"] = 2
					var player = get_tree().get_first_node_in_group("player")
					Global.save(Global.game_settings["word"])
					if Global.game_settings["gui_settings"]["Language"] == "русский":
						player.warning("Все уровни открыты!")
					else:
						player.warning("All levels are unlocked!")
					player.openUI("planet")
					queue_free()
				"sandbox":
					SceneManager.load_scene_with_loading("res://game/rooms/maps/simulation/sandbox.tscn")
				"FNaD":
					SceneManager.load_scene_with_loading("res://game/rooms/maps/RoP/fnaf.tscn")
				"flat":
					SceneManager.load_scene_with_loading("res://game/rooms/maps/simulation/flat.tscn")
				"parkour":
					SceneManager.load_scene_with_loading("res://game/rooms/maps/endless_parkour/endless_parkour.tscn")
		"other":
			match id:
				"console": 
					var player = get_tree().get_first_node_in_group("player")
					player.openUI("cheat")
					queue_free()
				"god": 
					var player = get_tree().get_first_node_in_group("player")
					player.GodMod = !player.GodMod
					player.warning("God mode changed [" + str(player.GodMod) + "]")
					Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
					Global.game_settings["UI"] = false
					queue_free()
				"infE": 
					var player = get_tree().get_first_node_in_group("player")
					player.infE = !player.infE
					player.warning("infE mode changed [" + str(player.infE) + "]")
					Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
					Global.game_settings["UI"] = false
					queue_free()
				"noclip [V]":
					var player = get_tree().get_first_node_in_group("player")
					player.noclip_cheat()
					player.warning("Noclip toggled")
					Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
					Global.game_settings["UI"] = false
					queue_free()
				"ghost":
					var player = get_tree().get_first_node_in_group("player")
					Global.game_settings["GhostMod"] = !Global.game_settings["GhostMod"]
					player.warning("Ghost mode changed [" + str(Global.game_settings["GhostMod"]) + "]")
					Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
					Global.game_settings["UI"] = false
					queue_free()
				"kill All":
					var player = get_tree().get_first_node_in_group("player")
					var enemies = get_tree().get_nodes_in_group("enemy")
					if enemies.size() > 0:
						for enemy in enemies:
							if enemy.has_method("take_damage"):
								enemy.take_damage(999999)
						player.warning("Killed " + str(enemies.size()) + " enemy/enemies")
					else:
						player.warning("No enemies found")
					Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
					Global.game_settings["UI"] = false
					queue_free()
				"clear charact": 
					_clear_group("enemy")
				"clear props": 
					_clear_group("prop")
				"clear balls": 
					_clear_group("balls")
				"clear blocks": 
					_clear_group("block")

func _clear_group(group_name: String) -> void:
	var nodes = get_tree().get_nodes_in_group(group_name)
	for node in nodes:
		if node and is_instance_valid(node):
			node.queue_free()
	print("Удалено ", nodes.size(), " объектов из группы: ", group_name)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Global.game_settings["UI"] = false
	queue_free()

func _on_label_button_pressed(id: String) -> void:
	match id:
		"set_item":
			var line_edit = $item_slot/LineEdit
			var input_text = line_edit.text.strip_edges()
			var new_value: int = 0
			if input_text.is_valid_int():
				new_value = input_text.to_int()
			else:
				new_value = 0
			if new_value < 0:
				new_value = 0
			if new_value > 999999:
				new_value = 999999
			var inventory = Global.get_world(Global.game_settings.word)["inventory"]
			if new_value == 0:
				if current_item_id in inventory:
					inventory.erase(current_item_id)
			else:
				inventory[current_item_id] = new_value
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			Global.game_settings["UI"] = false
			queue_free()
		"set_enemy":
			var line_edit = $Enemy_slot/LineEdit
			var input_text = line_edit.text.strip_edges()
			var new_value: int = 0
			if input_text.is_valid_int():
				new_value = input_text.to_int()
			else:
				new_value = 0
			if new_value < 0:
				new_value = 0
			if new_value > 10:
				new_value = 10
			Global.game_settings["summon"]["boss"] = $Enemy_slot/CheckBox.button_pressed
			Global.game_settings["summon"]["aura"] = new_value
			get_tree().get_first_node_in_group("player").weapon_system.equip_weapon("Summon")
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

func _on_weapon_slot_selected(slot_index: int, weapon_name: String) -> void:
	var player = get_tree().get_first_node_in_group("player")
	player.weapon_system.weapon_slots[slot_index] = weapon_name
	player.weapon_system.equip_weapon(player.weapon_system.weapon_slots.get(slot_index, ""))
	print("Оружие ", weapon_name, " установлено в слот ", slot_index)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Global.game_settings["UI"] = false
	queue_free()

func _update_item_display() -> void:
	var line_edit = $item_slot/LineEdit
	var inventory = Global.get_world(Global.game_settings.word)["inventory"]
	if current_item_id in inventory:
		line_edit.text = str(int(inventory[current_item_id]))
	else:
		line_edit.text = "0"
