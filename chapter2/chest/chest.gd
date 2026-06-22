extends Area3D

@export var stage_random: int = 1
@export var fixed_items: Array[String] = []

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

var item_icons = {
	"iron": preload("res://assets/item/iron.png"),
	"iron plate": preload("res://assets/item/iron_plate.png"),
	"copper": preload("res://assets/item/copper.png"),
	"copper cable": preload("res://assets/item/copper_cable.png"),
	"glass panel": preload("res://assets/item/glass_panel.png"),
	"coal": preload("res://assets/item/coal.png"),
	"quartz": preload("res://assets/item/quartz.png"),
	"schematic": preload("res://assets/item/schematic.png")
}

var _secondary_color: Color
var _chest_items: Array = []

func _ready() -> void:
	if fixed_items.size() > 0:
		_chest_items = fixed_items.duplicate()
	else:
		_chest_items = generate_random_inventory(stage_random)
	_secondary_color = Color("82594e").darkened(0.1)

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
	_add_items_to_player_inventory()
	_show_chest_content()
	$Sprite3D.modulate = _secondary_color
	$Sprite3D.shaded = true
	$Sprite3D/OmniLight3D.queue_free()
	remove_from_group("interactive_objects")

func _add_items_to_player_inventory():
	var world_data = Global.get_world(Global.game_settings.word)
	for item in _chest_items:
		if item != "":
			world_data.inventory["inventory"].append(item)

func _on_mouse_entered() -> void:
	pass

func _on_mouse_exited() -> void:
	pass
	
func _show_chest_content():
	var vbox = $CanvasLayer/VBoxContainer
	var font = load("res://Undertale-Battle-Font.ttf-5b3f8609511f8e0c8fc5e3287eaa9635.fontdata")
	for item in _chest_items:
		if item != "":
			var hbox = HBoxContainer.new()
			hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			var icon = TextureRect.new()
			icon.texture = _get_item_texture(item)
			hbox.add_child(icon)
			var label = Label.new()
			label.text = "+ " + item.capitalize()
			label.add_theme_font_override("font", font)
			label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			hbox.add_child(label)
			var spacer = Control.new()
			spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			hbox.add_child(spacer)
			vbox.add_child(hbox)
	$CanvasLayer/AnimationPlayer.play("show")

func _get_item_texture(item_name: String) -> Texture2D:
	if item_icons.has(item_name):
		return item_icons[item_name]
	else:
		return item_icons["schematic"]
