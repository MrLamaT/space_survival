extends Control

@export var sprite_texture: Texture
@export var sprite_label: String = ""
@export var required_resources: Array[String] = []
@export var required_description: String = ""
@export var build_global: String = ""
@export var build_global_min: int = 0
@export var build_global_max: int = 0
@onready var billboard_sprite: Sprite2D = $Sprite2D
@onready var billboard_label: Label = $Label

var player: CharacterBody3D

func _ready():
	if billboard_sprite:
		var world = Global.get_world(Global.game_settings.word)
		$Sprite2D.texture = sprite_texture
		visible = true
		billboard_label.text = sprite_label
		if build_global != "" and (world["build"][build_global] < build_global_min or  world["build"][build_global] > build_global_max):
			queue_free()

func check_and_consume_resources() -> bool:
	if required_resources.size() == 0:
		return true
	var world = Global.get_world(Global.game_settings.word)
	if not world or not world.has("inventory"):
		push_error("World or inventory not found!")
		return false
	var inventory = world["inventory"]["inventory"]
	var required_counts = {}
	for resource in required_resources:
		if resource in required_counts:
			required_counts[resource] += 1
		else:
			required_counts[resource] = 1
	var available_counts = {}
	for resource in inventory:
		if resource in available_counts:
			available_counts[resource] += 1
		else:
			available_counts[resource] = 1
	var missing_resources = []
	for resource_type in required_counts:
		var required_count = required_counts[resource_type]
		var available_count = available_counts.get(resource_type, 0)
		if available_count < required_count:
			var missing = required_count - available_count
			missing_resources.append("%s x%d" % [resource_type, missing])
	if missing_resources.size() > 0:
		if Global.game_settings["gui_settings"]["Language"] == "русский":
			player.warning("Недостаточно ресурсов!")
		else:
			player.warning("Not enough resources!")
		return false
	for resource_type in required_counts:
		var count_to_remove = required_counts[resource_type]
		var removed_count = 0
		for i in range(inventory.size() - 1, -1, -1):  # Идем с конца, чтобы не ломать индексы
			if removed_count >= count_to_remove:
				break
			if inventory[i] == resource_type:
				inventory.remove_at(i)
				removed_count += 1
	return true

func _on_button_pressed() -> void:
	if !check_and_consume_resources():
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		get_parent().get_parent().get_parent().queue_free()
		return
	if sprite_label == "decipher the recipe":
		var world = Global.get_world(Global.game_settings.word)
		var available_builds = []
		for key in world["build"]:
			if world["build"][key] == -1:
				available_builds.append(key)
		if available_builds.size() > 0:
			var random_index = randi() % available_builds.size()
			var selected_key = available_builds[random_index]
			world["build"][selected_key] = 0
			if Global.game_settings["gui_settings"]["Language"] == "русский":
				player.warning("Новый чертёж получен!")
			else:
				player.warning("New blueprint acquired!")
		else:
			if Global.game_settings["gui_settings"]["Language"] == "русский":
				player.warning("Нет новых чертежей для текущего этапа.")
			else:
				player.warning("No new blueprints available for current stage.")
	if sprite_label == "copper cable":
		var world = Global.get_world(Global.game_settings.word)
		world["inventory"]["inventory"].append("copper cable")
	if sprite_label == "backpack 1":
		var world = Global.get_world(Global.game_settings.word)
		world["build"]["backpack"] += 1
	if sprite_label == "flashlight 1":
		var world = Global.get_world(Global.game_settings.word)
		world["build"]["flashlight"] += 1
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_parent().get_parent().get_parent().queue_free()

func _on_button_mouse_entered() -> void:
	$Label.modulate = Color("faff68")
	player = get_tree().get_first_node_in_group("player")
	player.recipe(required_resources, sprite_label, required_description)

func _on_button_mouse_exited() -> void:
	$Label.modulate = Color("ffffffff")
	player = get_tree().get_first_node_in_group("player")
	player.recipe([], "", "")
