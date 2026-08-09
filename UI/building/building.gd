extends Node2D

func _ready() -> void:
	var current_language = Global.game_settings["gui_settings"]["Language"]
	if current_language == "русский":
		$Panel/equipmentLabel.text = "МАГАЗИН"
	else:
		$Panel/equipmentLabel.text = "SHOP"
	
	var world = Global.get_world(Global.game_settings.word)
	var equipment_container = $Panel/equipment
	
	for child in equipment_container.get_children():
		var sprite_label_value = child["sprite_label"]
		if sprite_label_value != null and sprite_label_value in world["equipment"]:
			child.get_node("Sprite2D2").visible = true

func create(sprite_label):
	var world = Global.get_world(Global.game_settings.word)
	var player = get_tree().get_first_node_in_group("player")
	world["equipment"].append(sprite_label)
	player.update_max_stamina()
	player.save()
	player.get_node("craft").play()
	$InventoryUi.update()
	_ready()
