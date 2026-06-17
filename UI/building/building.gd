extends Node2D

func _ready() -> void:
	$Panel/equipmentButton.visible = true
	$Panel/buildingsButton.visible = false
	$Panel/buildings.visible = true
	$Panel/equipment.visible = false
	$Panel/buildingsLabel.visible = true
	$Panel/equipmentLabel.visible = false
	var current_language = Global.game_settings["gui_settings"]["Language"]
	if current_language == "русский":
		$Panel/buildingsLabel.text = "Корабль — это дом. А дом нужно обустраивать с умом."
		$Panel/equipmentLabel.text = "Качество сборки напрямую влияет на продолжительность вашей жизни."
	else:
		$Panel/buildingsLabel.text = "The ship is a home. And a home must be furnished wisely."
		$Panel/equipmentLabel.text = "Build quality directly affects your lifespan."
	
	var world = Global.get_world(Global.game_settings.word)
	var equipment_container = $Panel/equipment
	
	if equipment_container:
		for child in equipment_container.get_children():
			var sprite_label_value = child["sprite_label"]
			if sprite_label_value != null and sprite_label_value in world["equipment"]:
				child.queue_free()

func _on_label_button_pressed(_id: String) -> void:
	$Panel/equipmentButton.visible = !$Panel/equipmentButton.visible
	$Panel/buildingsButton.visible = !$Panel/buildingsButton.visible
	$Panel/buildings.visible = !$Panel/buildings.visible
	$Panel/equipment.visible = !$Panel/equipment.visible
	$Panel/buildingsLabel.visible = !$Panel/buildingsLabel.visible
	$Panel/equipmentLabel.visible = !$Panel/equipmentLabel.visible

func create(sprite_label, containerName):
	var world = Global.get_world(Global.game_settings.word)
	var player = get_tree().get_first_node_in_group("player")
	if containerName == "equipment":
		world["equipment"].append(sprite_label)
		player.save()
	else:
		get_tree().current_scene.handle_interaction(sprite_label)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Global.game_settings["UI"] = false
	player.get_node("craft").play()
	queue_free()
