extends Node2D

func _on_label_button_pressed(id: String) -> void:
	Global.summon["enemyTags"] = id
	Global.close_ui_and_resume_game(self)
