extends Control

func _on_button_pressed() -> void:
	pass # Replace with function body.

func _on_button_mouse_entered() -> void:
	scale = Vector2(1.1, 1.1)

func _on_button_mouse_exited() -> void:
	scale = Vector2(1.0, 1.0)
