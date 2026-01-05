extends Node3D

@onready var collision_area = $Area3D
var check = true
var possible_positions = [
	Vector3(-7.0, 7.674, -19.0),
	Vector3(-20.0, 7.674, -15.0)
]
var available_positions = []
var last_used_position = null

func _ready() -> void:
	if !Global.game_settings["debugging"]:
		$test.queue_free()
	else:
		$test.visible = true
	available_positions = possible_positions.duplicate()
	set_random_position_from_list()

func _on_body_entered(body):
	if body.is_in_group("enemy2"):
		target_reached(body)

func target_reached(_enemy):
	set_random_position_from_list()
	check = !check
	print("Цель достигнута врагом!")

func _on_timer_timeout() -> void:
	set_random_position_from_list()

func timeStart():
	$Timer.start()

func set_random_position_from_list():
	# Если доступных позиций не осталось, перезаполняем все кроме последней использованной
	if available_positions.size() == 0:
		reset_available_positions()
	# Выбираем случайную позицию из доступных
	var random_index = randi() % available_positions.size()
	last_used_position = available_positions[random_index]
	global_position = last_used_position
	# Удаляем использованную позицию из доступных
	available_positions.remove_at(random_index)
	print("Установлена позиция: ", last_used_position)
	print("Осталось доступных позиций: ", available_positions.size())
	
func reset_available_positions():
	available_positions = possible_positions.duplicate()
	if last_used_position != null:
		var index_to_remove = available_positions.find(last_used_position)
		if index_to_remove != -1:
			available_positions.remove_at(index_to_remove)
	print("Перезаполнены доступные позиции (все кроме последней)")
