extends Node2D

var world = Global.get_world(Global.game_settings.word)

func _ready() -> void:
	$Panel/Id.text = world["selectWorld"]

func _on_label_button_pressed(id: String) -> void:
	match id:
		"next":
			reload()

func reload():
	var keys_to_remove = []
	for key in world["inventory"].keys():
		if key is String and "chest_W" in key:
			keys_to_remove.append(key)
	for key in keys_to_remove:
		world["inventory"].erase(key)
