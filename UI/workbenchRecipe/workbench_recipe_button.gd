extends Control

@export var interaction_name: String = "" 
@export var handler_node: NodePath 
@export var handler_method: String = "handle_interaction" 
@export var sprite_label: String = ""
@export var required_resources: Array[String] = []
@export var required_description: String = ""
@onready var billboard_sprite: Sprite2D = $Sprite2D
@onready var billboard_label: Label = $Label

var player: CharacterBody3D

func _ready():
	if billboard_sprite:
		visible = true
		billboard_label.text = sprite_label
	if interaction_name == "":
		push_warning("InteractableObject at %s has no interaction name set!" % global_position)
	if handler_node.is_empty():
		push_warning("InteractableObject at %s has no handler node set!" % global_position)

func trigger_interaction():
	if !check_and_consume_resources():
		return
	var target_node = get_node(handler_node)
	if target_node and target_node.has_method(handler_method):
		target_node.call(handler_method, interaction_name)
	else:
		push_error("Handler node or method not found for interaction: %s" % interaction_name)

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

func _on_button_focus_entered() -> void:
	player = get_tree().get_first_node_in_group("player")
	player.recipe(required_resources, sprite_label, required_description)

func _on_button_focus_exited() -> void:
	player = get_tree().get_first_node_in_group("player")
	player.recipe([], "", "")
