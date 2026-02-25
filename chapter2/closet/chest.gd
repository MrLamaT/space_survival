extends Area3D

@export var chest: String
@export var _base_color: Color
@export var _base_sprite: Texture

var stage_items = {
	1: {
		"common": ["iron", "copper", "coal"],      
		"rare": ["quartz", "schematic"]                      
	},
	2: {
		"common": ["iron", "copper", "coal"],
		"rare": ["quartz", "schematic"]
	}
}

var chance_settings = {
	"common": 0.9, 
	"rare": 0.1
}

var _secondary_color: Color

func _ready() -> void:
	var world_data = Global.get_world(Global.game_settings.word)
	var current_stage = world_data.stage
	if world_data.inventory.has(chest):
		if world_data.inventory[chest] == ["NoSpawn"]:
			queue_free()
			return
	if not world_data.inventory.has(chest):
		if randf() < 0.5:
			world_data.inventory[chest] = ["NoSpawn"]
			queue_free()
			return
		world_data.inventory[chest] = generate_random_inventory(current_stage)
	ApplyingSkin()

func ApplyingSkin():
	var material = StandardMaterial3D.new()
	material.albedo_color = _base_color
	$MeshInstance3D.material_override = material
	_secondary_color = _base_color.darkened(0.3)
	$Sprite3D.texture = _base_sprite
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
