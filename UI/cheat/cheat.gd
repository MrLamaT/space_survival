extends Node2D

func _on_label_button_pressed(id: String) -> void:
	$Panel/Terminal.parse_command(id)
