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
				"RoP-856":
					var player = get_tree().get_first_node_in_group("player")
					player.gravity = ProjectSettings.get_setting("physics/3d/default_gravity") / 2
				"Supermass":
					var player = get_tree().get_first_node_in_group("player")
					player.gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * 2
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
		"block":
			Global.game_settings["summon"]["name"] = "block"
			Global.game_settings["summon_block"]["texture"] = ""
			match id:
				"plank": 
					Global.game_settings["summon_block"]["texture"] = "res://assets/material/plank.tres"
				"grass": 
					Global.game_settings["summon_block"]["texture"] = "res://assets/material/earth.tres"
				"grid": 
					Global.game_settings["summon_block"]["texture"] = "res://assets/material/grid.tres"
				"sand": 
					Global.game_settings["summon_block"]["texture"] = "res://assets/material/sand.tres"
				"stone": 
					Global.game_settings["summon_block"]["texture"] = "res://assets/material/RoPstone.tres"
			Global.game_settings["summon_block"]["color"] = str(color_img.to_html())
			get_tree().get_first_node_in_group("player").weapon_system.equip_weapon("Summon")
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

func _ready() -> void:
	$Panel/ScrollContainer.scroll_vertical = int(Global.game_settings["spawn_scroll_position"])

func _exit_tree():
	Global.game_settings["spawn_scroll_position"] = $Panel/ScrollContainer.scroll_vertical
