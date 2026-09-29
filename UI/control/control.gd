extends Node2D

@onready var control_panel = $Panel/control/VBoxContainer

func _ready() -> void:
	print("========== InputMap проекта ==========")
	
	# Получаем список всех действий (actions) в InputMap
	var actions: Array = InputMap.get_actions()
	actions.sort()  # сортируем по алфавиту для удобства
	
	for action in actions:
		# Пропускаем встроенные ui_* действия, если нужно
		# if action.begins_with("ui_"):
		# 	continue
		
		print("\n[Action]: ", action)
		
		# Получаем список событий, привязанных к действию
		var events: Array = InputMap.action_get_events(action)
		
		if events.is_empty():
			print("   (нет привязанных событий)")
			continue
		
		for event in events:
			print("   -> ", _event_to_string(event))

	print("\n======================================")

func _event_to_string(event: InputEvent) -> String:
	if event is InputEventKey:
		var key_event := event as InputEventKey
		var mods := _get_modifiers_string(key_event)
		return "Клавиша: %s%s" % [mods, OS.get_keycode_string(key_event.physical_keycode)]
	
	elif event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		return "Мышь (кнопка): %s" % _mouse_button_name(mb.button_index)
	
	elif event is InputEventMouseMotion:
		return "Мышь (движение)"
	
	elif event is InputEventJoypadButton:
		var jb := event as InputEventJoypadButton
		return "Геймпад (кнопка): %d" % jb.button_index
	
	elif event is InputEventJoypadMotion:
		var jm := event as InputEventJoypadMotion
		return "Геймпад (ось): %d, значение: %.2f" % [jm.axis, jm.axis_value]
	
	elif event is InputEventAction:
		var ia := event as InputEventAction
		return "Действие: %s" % ia.action
	
	return "Неизвестное событие: %s" % event


func _get_modifiers_string(event: InputEventKey) -> String:
	var mods := ""
	if event.ctrl_pressed:
		mods += "Ctrl+"
	if event.shift_pressed:
		mods += "Shift+"
	if event.alt_pressed:
		mods += "Alt+"
	if event.meta_pressed:
		mods += "Meta+"
	return mods


func _mouse_button_name(index: int) -> String:
	match index:
		MOUSE_BUTTON_LEFT:   return "Левая"
		MOUSE_BUTTON_RIGHT:  return "Правая"
		MOUSE_BUTTON_MIDDLE: return "Средняя"
		MOUSE_BUTTON_WHEEL_UP:   return "Колесо вверх"
		MOUSE_BUTTON_WHEEL_DOWN: return "Колесо вниз"
		MOUSE_BUTTON_XBUTTON1:   return "Боковая 1"
		MOUSE_BUTTON_XBUTTON2:   return "Боковая 2"
		_: return "Кнопка %d" % index
