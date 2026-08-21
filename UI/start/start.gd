extends Node2D

@export var typing_speed: float = 0.025

var skip_typing: bool = false
var is_typing: bool = false

func _ready() -> void:
	start_typing_effect("Select language")
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		skip_typing = true

func start_typing_effect(full_text: String) -> void:
	$language/Label.text = ""
	await type_text($language/Label, full_text)
	await get_tree().create_timer(0.5).timeout
	$language/AnimationPlayer.play("language")

func type_text(label, text: String) -> void:
	is_typing = true
	skip_typing = false
	for i in range(text.length()):
		if skip_typing:
			label.text = text
			break
		label.text += text[i]
		await get_tree().create_timer(typing_speed).timeout
	is_typing = false
	skip_typing = false

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
	$Panel/Sprite2D.visible = true
	

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
	$Panel/Sprite2D.visible = true
	
func _on_En_mouse_entered() -> void:
	$language/usa.scale = Vector2(1.25, 1.25)

func _on_En_mouse_exited() -> void:
	$language/usa.scale = Vector2(1.0, 1.0)

func _on_Ru_mouse_entered() -> void:
	$language/ru.scale = Vector2(1.25, 1.25)

func _on_Ru_mouse_exited() -> void:
	$language/ru.scale = Vector2(1.0, 1.0)

var page = 0

func _on_label_button_pressed(_id: String) -> void:
	page += 1
	$Panel/Label.text = ""
	$Panel/Sprite2D.visible = false
	if page == 1:
		if Global.game_settings["gui_settings"]["Language"] == "русский":
			await type_text($Panel/Label, "Движение
W, A, S, D — передвижение
Shift — бег
Space — прыжок
C, ctrl — присесть

Взаимодействие с миром
E — взаимодействие с объектами
F — включить/выключить фонарик

оружия
1–5 — слоты оружия
ЛКМ — стрельба")
		else:
			await type_text($Panel/Label, "W, A, S, D — movement
Shift — sprint
Space — jump
C, Ctrl — crouch

Interaction with the world
E — interact with objects
F — toggle flashlight

Weapons
1–5 — weapon slots
LMB — shoot")
	if page >= 2:
		SceneManager.load_scene_with_loading("res://chapter2/rooms/maps/simulation/training.tscn")
