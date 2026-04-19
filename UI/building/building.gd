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
	
	var world = Global.get_world(Global.game_settings.word)
	var equipment_container = $Panel/equipment
	
	if equipment_container:
		for child in equipment_container.get_children():
			var sprite_label_value = child["sprite_label"]
			if sprite_label_value != null and sprite_label_value in world["equipment"]:
				child.queue_free()
	
	var current_language = Global.game_settings["gui_settings"]["Language"]
	var random_index = randi() % phrases["русский"].size()
	
	if current_language == "русский":
		$Panel/Label.text = phrases["русский"][random_index]
	else:
		$Panel/Label.text = phrases["english"][random_index]

func create(sprite_label):
	var world = Global.get_world(Global.game_settings.word)
	world["equipment"].append(sprite_label)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Global.game_settings["UI"] = false
	queue_free()
