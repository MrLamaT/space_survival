extends Node2D

func _on_label_button_pressed(id: String) -> void:
	match id:
		"play":
			visible = false
			get_parent().get_node("world").visible = true
			$beep.play()
		"options":
			visible = false
			get_parent().get_node("options").visible = true
			$beep.play()
		"quit":
			get_tree().quit()
