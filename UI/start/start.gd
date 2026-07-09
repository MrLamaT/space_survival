extends Node2D

@export var typing_speed: float = 0.025

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
	await type_text($Panel/Label, "STATUS: Cleaner
Objective: Infiltrate through the portal, neutralize all hostiles that have lost 
control, reach the activation point, and initiate the object's detonation.
Assets: Any found on-site. Weapon acquisition, resource gathering, and equipment 
modification are encouraged.
Outcome: In the event of death — written off without debriefing.")
	$Panel/LabelButton.visible = true
	

func _on_Ru_pressed() -> void:
	Global.game_settings["gui_settings"]["Language"] = "русский"
	$language.visible = false
	$Panel.visible = true
	await type_text($Panel/Label, "СТАТУС: Чистильщик
Задача: Проникнуть через портал, нейтрализовать все цели, утратившие контроль, 
добраться до точки активации и инициировать подрыв объекта.
Средства: Любые, найденные на месте. Сбор вооружения, ресурсов и модификация 
экипировки поощряются.
Итог: В случае гибели — списание без отчёта.")
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
