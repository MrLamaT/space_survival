extends Node2D

var world = Global.get_world(Global.game_settings.word)

func _ready() -> void:
	if world["selectWorld"] != 0:
		$load/AnimationPlayer.play("load")
		$load/AnimationPlayer.advance($load/AnimationPlayer.current_animation_length)
		$Panel/Id.text = world["selectWorldName"]
		$Panel/LabelButton.visible = false
		$Panel/LabelButton2.visible = true
	else:
		$load/AnimationPlayer.play("load")
		$Panel/LabelButton.visible = true
		$Panel/LabelButton2.visible = false

func _on_label_button_pressed(id: String) -> void:
	match id:
		"open":
			world["selectWorld"] = 1
			world["selectWorldName"] = $Panel/Id.text
			$Panel/LabelButton.visible = false
			$Panel/LabelButton2.visible = true
		"close":
			world["selectWorld"] = 0
			$load/AnimationPlayer.play("load")
			$Panel/LabelButton.visible = true
			$Panel/LabelButton2.visible = false

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "load":
		$Panel/Id.text = "ID planet: RoP-856/%02d" % randi_range(10, 99)
