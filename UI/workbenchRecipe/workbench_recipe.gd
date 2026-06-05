extends Node2D

func _ready() -> void:
	var phrases = {
		"русский": [
			"Верстак. Место, где из беспорядка рождается порядок.",
			"Производственный модуль активирован. Соблюдайте технику безопасности.",
			"Старый добрый верстак. Сколько же всего здесь было создано...",
			"Все системы в идеальном состоянии. Можно запускать производство."
		],
		"english": [
			"Workbench. The place where order emerges from chaos.",
			"Fabrication module activated. Please follow safety precautions.",
			"Good old workbench. So many things have been created here...",
			"All systems in perfect condition. Ready to start fabrication."
		]
	}
	
	var current_language = Global.game_settings["gui_settings"]["Language"]
	var random_index = randi() % phrases["русский"].size()
	
	if current_language == "русский":
		$Panel/Label.text = phrases["русский"][random_index]
	else:
		$Panel/Label.text = phrases["english"][random_index]

func create(sprite_label, _containerName):
	var world = Global.get_world(Global.game_settings.word)
	world["inventory"]["inventory"].append(sprite_label)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Global.game_settings["UI"] = false
	var player = get_tree().get_first_node_in_group("player")
	player.get_node("craft").play()
	queue_free()
