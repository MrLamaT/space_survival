extends Area3D

@export var stage_random: int = 1

var stage_items = {
	0: {
		"common": {
			"Credits": {"min": 10, "max": 10}
		},      
		"rare": {}
	},
	1: {
		"common": {
			"Credits": {"min": 10, "max": 15}
		},      
		"rare": {}
	},
	2: {
		"common": {
			"Credits": {"min": 15, "max": 20}
		},      
		"rare": {}
	},
	3: {
		"common": {
			"Credits": {"min": 100, "max": 110}
		},      
		"rare": {}
	},
	4: {
		"common": {
			"Credits": {"min": 200, "max": 250}
		},      
		"rare": {}
	},
	5: {
		"common": {
			"Credits": {"min": 500, "max": 550}
		},      
		"rare": {}
	},
	6: {
		"common": {
			"Credits": {"min": 600, "max": 750}
		},      
		"rare": {}
	},
	7: {
		"common": {
			"Credits": {"min": 750, "max": 800}
		},
		"rare": {
			"Sercilist": {"chance": 0.1, "min": 1, "max": 1}
		}
	},
	8: {
		"common": {
			"Credits": {"min": 900, "max": 1000}
		},
		"rare": {
			"Sercilist": {"chance": 0.2, "min": 1, "max": 1}
		}
	},
	9: {
		"common": {
			"Credits": {"min": 1000, "max": 1500}
		},
		"rare": {
			"Sercilist": {"chance": 0.2, "min": 1, "max": 1}
		}
	},
	10: {
		"common": {
			"Credits": {"min": 2000, "max": 2250}
		},
		"rare": {
			"Sercilist": {"chance": 0.2, "min": 1, "max": 1}
		}
	},
	11: {
		"common": {
			"Credits": {"min": 2500, "max": 2750}
		},
		"rare": {
			"Sercilist": {"chance": 0.3, "min": 1, "max": 1}
		}
	},
	12: {
		"common": {
			"Credits": {"min": 3000, "max": 3250}
		},
		"rare": {
			"Sercilist": {"chance": 0.3, "min": 1, "max": 1}
		}
	},
	13: {
		"common": {
			"Credits": {"min": 3500, "max": 3750}
		},
		"rare": {
			"Sercilist": {"chance": 0.3, "min": 1, "max": 1}
		}
	},
	14: {
		"common": {
			"Credits": {"min": 4000, "max": 4250}
		},
		"rare": {
			"Sercilist": {"chance": 0.4, "min": 1, "max": 1},
			"Dark Sercilist": {"chance": 0.1, "min": 1, "max": 1},
		}
	},
	15: {
		"common": {
			"Credits": {"min": 4500, "max": 4750}
		},
		"rare": {
			"Sercilist": {"chance": 0.4, "min": 1, "max": 1},
			"Dark Sercilist": {"chance": 0.1, "min": 1, "max": 1},
		}
	},
	16: {
		"common": {
			"Credits": {"min": 4800, "max": 5000}
		},
		"rare": {
			"Sercilist": {"chance": 0.5, "min": 1, "max": 3},
			"Dark Sercilist": {"chance": 0.1, "min": 1, "max": 1},
		}
	}
}

var item_icons = {
	"schematic": preload("res://assets/item/schematic.png"),
	"Credits": preload("res://assets/item/credits.png"),
	"Sercilist": preload("res://assets/item/sercilist.png"),
	"Dark Sercilist": preload("res://assets/item/dark_sercilist.png")
}

var _secondary_color: Color
var _chest_items: Dictionary = {}

func _ready() -> void:
	_chest_items = generate_random_inventory(stage_random)
	_secondary_color = Color("616380").darkened(0.1)

func generate_random_inventory(stage: int) -> Dictionary:
	var inventory = {}
	var items = stage_items.get(stage, stage_items[1])
	for item_name in items["common"]:
		var item_data = items["common"][item_name]
		var count = randi() % (item_data["max"] - item_data["min"] + 1) + item_data["min"]
		inventory[item_name] = count
	for item_name in items["rare"]:
		var item_data = items["rare"][item_name]
		var chance = item_data["chance"]
		if randf() < chance:
			var count = randi() % (item_data["max"] - item_data["min"] + 1) + item_data["min"]
			inventory[item_name] = count
	return inventory

func trigger_interaction():
	_add_items_to_player_inventory()
	_show_chest_content()
	$Sprite3D.modulate = _secondary_color
	$Sprite3D.shaded = true
	$AnimationPlayer.play("open")
	remove_from_group("interactive_objects")

func _add_items_to_player_inventory():
	var world_data = Global.get_world(Global.game_settings.word)
	for item_name in _chest_items:
		var count = _chest_items[item_name]
		if world_data.inventory.has(item_name):
			world_data.inventory[item_name] += count
		else:
			world_data.inventory[item_name] = count

func _on_mouse_entered() -> void:
	pass

func _on_mouse_exited() -> void:
	pass
	
func _show_chest_content():
	var vbox = $CanvasLayer/VBoxContainer
	var font = load("res://Undertale-Battle-Font.ttf-5b3f8609511f8e0c8fc5e3287eaa9635.fontdata")
	for item_name in _chest_items:
		var count = _chest_items[item_name]
		var hbox = HBoxContainer.new()
		hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var icon = TextureRect.new()
		icon.texture = _get_item_texture(item_name)
		hbox.add_child(icon)
		var label = Label.new()
		label.text = "+ " + str(count) + " " + item_name.capitalize()
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
