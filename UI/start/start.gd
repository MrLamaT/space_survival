extends Node2D

@export var typing_speed: float = 0.05

func _ready() -> void:
	start_typing_effect("Select language")

func start_typing_effect(full_text: String) -> void:
	$language/Label.text = ""
	await type_text($language/Label, full_text)
	await get_tree().create_timer(0.5).timeout
	$language/AnimationPlayer.play("language")

func type_text(label, text: String) -> void:
	for i in range(text.length()):
		label.text += text[i]
		await get_tree().create_timer(typing_speed).timeout

func _on_En_pressed() -> void:
	Global.game_settings["gui_settings"]["Language"] = "English"
	$language.visible = false
	$Panel.visible = true
	await type_text($Panel/Label, "Welcome aboard, Purifier.

Mission Objective: Infiltrate the level via portal, neutralize all threats, and 
evacuate before the portal closes.

Protocol: Tactical flexibility and freedom of route choice are permitted. Survey 
your surroundings, gather resources for crafting and gear upgrades. Utilize 
discovered weapons and tools to complete your objectives.")
	$Panel/LabelButton.visible = true
	

func _on_Ru_pressed() -> void:
	Global.game_settings["gui_settings"]["Language"] = "русский"
	$language.visible = false
	$Panel.visible = true
	await type_text($Panel/Label, "Добро пожаловать на борт, Чистильщик.

Цель миссии: Проникнуть на уровень через портал, нейтрализовать угрозы и 
эвакуироваться до закрытия портала.

Протокол: Вам доступны тактическая гибкость и свобода выбора маршрута. 
Изучайте окружение, собирайте ресурсы для крафта и улучшения экипировки. Для 
прохождения используйте найденное оружие и инструменты.")
	$Panel/LabelButton.visible = true
	
func _on_En_mouse_entered() -> void:
	$language/usa.scale = Vector2(1.25, 1.25)

func _on_En_mouse_exited() -> void:
	$language/usa.scale = Vector2(1.0, 1.0)

func _on_Ru_mouse_entered() -> void:
	$language/ru.scale = Vector2(1.25, 1.25)

func _on_Ru_mouse_exited() -> void:
	$language/ru.scale = Vector2(1.0, 1.0)

func _on_label_button_pressed(_id: String) -> void:
	SceneManager.load_scene_with_loading("res://chapter2/rooms/maps/training.tscn")
