extends Node2D

var world = Global.get_world(Global.game_settings.word)
var portal = null

func _ready() -> void:
	portal = get_tree().get_first_node_in_group("portal")
	reload()

func _on_label_button_pressed(id: String) -> void:
	match id:
		"previous":
			reload()
		"next":
			reload()

func reload():
	var keys_to_remove = []
	for key in world["inventory"].keys():
		if key is String and "chest_W" in key:
			keys_to_remove.append(key)
	for key in keys_to_remove:
		world["inventory"].erase(key)

func _on_button_pressed_1() -> void:
	portal.teleport("res://chapter2/rooms/maps/RoP/RoP_1.tscn")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Global.game_settings["UI"] = false
	queue_free()

func _on_button_pressed_2() -> void:
	portal.teleport("res://chapter2/rooms/maps/RoP/RoP_1.tscn")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Global.game_settings["UI"] = false
	queue_free()

func _on_button_pressed_3() -> void:
	portal.teleport("res://chapter2/rooms/maps/RoP/RoP_1.tscn")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Global.game_settings["UI"] = false
	queue_free()

func _on_button_pressed_4() -> void:
	portal.teleport("res://chapter2/rooms/maps/RoP/RoP_1.tscn")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Global.game_settings["UI"] = false
	queue_free()
