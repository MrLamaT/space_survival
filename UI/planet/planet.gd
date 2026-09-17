extends Node2D

var world = Global.get_world(Global.game_settings.word)

func _on_label_button_pressed(id: String) -> void:
	match id:
		"back":
			$Panel/LabelButton.visible = false
			$Sprite2D.visible = false
			$Panel/Id.visible = false
			$Panel/ScrollContainer.visible = true
			
			$Panel/sim.visible = false
			$Panel/RoP.visible = false

func teleport(res):
	SceneManager.load_scene_with_loading(res)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Global.game_settings["UI"] = false
	queue_free()
