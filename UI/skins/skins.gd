extends Node2D

var current_item_id: String = ""

func handle_card_pressed(type, id, _color_img):
	match type:
		"costumes":
			var world = Global.get_world(Global.game_settings.word)
			world["costumes"] = id
			var hand_nodes = get_tree().get_nodes_in_group("hand")
			for node in hand_nodes:
				node.create_custom_material()
			Global.save(Global.game_settings["word"])
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			Global.game_settings["UI"] = false
			queue_free()
