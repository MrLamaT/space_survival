extends Node2D

func _ready() -> void:
	var current_language = Global.game_settings["gui_settings"]["Language"]
	if current_language == "русский":
		type_text("Качество сборки напрямую влияет на продолжительность вашей жизни.")
	else:
		type_text("Build quality directly affects your lifespan.")
	
	var world = Global.get_world(Global.game_settings.word)
	var equipment_container = $Panel/equipment
	
	for child in equipment_container.get_children():
		var sprite_label_value = child["sprite_label"]
		if sprite_label_value != null and sprite_label_value in world["equipment"]:
			child.queue_free()

func _on_label_button_pressed(_id: String) -> void:
	var player = get_tree().get_first_node_in_group("player")
	player.openUI("planet")
	queue_free()

func create(sprite_label, _containerName):
	var world = Global.get_world(Global.game_settings.word)
	var player = get_tree().get_first_node_in_group("player")
	world["equipment"].append(sprite_label)
	player.save()
	player.get_node("craft").play()
	_ready()

func type_text(text: String) -> void:
	for i in range(text.length()):
		$Panel/equipmentLabel.text += text[i]
		await get_tree().create_timer(0.05).timeout
