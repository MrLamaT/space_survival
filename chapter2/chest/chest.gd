extends Area3D

@export var chest: String = ""
@export var stage_random: int = 1
@export var generate_items: bool = true

var stage_items = {
	1: {
		"common": ["iron", "copper", "coal"],      
		"rare": ["quartz"]                      
	},
	2: {
		"common": ["schematic", "schematic", "schematic"],
		"rare": ["schematic"]
	}
}

var chance_settings = {
	"common": 0.8, 
	"rare": 0.2
}

var _secondary_color: Color

func _ready() -> void:
	var world_data = Global.get_world(Global.game_settings.word)
	if generate_items and not world_data.inventory.has(chest):
		world_data.inventory[chest] = generate_random_inventory(stage_random)
	elif not generate_items and not world_data.inventory.has(chest):
		world_data.inventory[chest] = []
	ApplyingSkin()

func generate_unique_chest_id(inventory_dict: Dictionary) -> String:
	var counter = 1
	while true:
		var candidate = "chest_" + str(counter)
		if not inventory_dict.has(candidate):
			return candidate
		counter += 1
	return ""

func ApplyingSkin():
	_secondary_color = Color("82594e").darkened(0.1)
	$Sprite3D.modulate = _secondary_color

func generate_random_inventory(stage: int) -> Array:
	var inventory = []
	var items = stage_items.get(stage, stage_items[1])  # по умолчанию stage1
	for i in range(4):
		var random_value = randf()
		var selected_item = ""
		if random_value < chance_settings["rare"]:
			if items["rare"].size() > 0:
				selected_item = items["rare"][randi() % items["rare"].size()]
		elif random_value < chance_settings["rare"] + chance_settings["common"]:
			if items["common"].size() > 0:
				selected_item = items["common"][randi() % items["common"].size()]
		inventory.append(selected_item)
	return inventory

func trigger_interaction():
	var player = get_tree().get_first_node_in_group("player")
	player.open_inventory(chest, "storage", 4, 1)

func _on_mouse_entered() -> void:
	$Sprite3D.modulate = Color("ffffffff")
	$Sprite3D.shaded = false
	$Sprite3D/OmniLight3D.visible = true

func _on_mouse_exited() -> void:
	$Sprite3D.modulate = _secondary_color
	$Sprite3D.shaded = true
	$Sprite3D/OmniLight3D.visible = false

func set_generate_items(value: bool):
	generate_items = value
	
func set_chest_name(new_chest_name: String):
	chest = new_chest_name
