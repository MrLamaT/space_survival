extends Node2D

var world = Global.get_world(Global.game_settings.word)

func _ready() -> void:
	if world["selectWorld"] != 0:
		$load/AnimationPlayer.play("load")
		$load/AnimationPlayer.advance($load/AnimationPlayer.current_animation_length)
		$Panel/Id.text = world["selectWorldName"]
	else:
		$load/AnimationPlayer.play("load")

func _on_label_button_pressed(id: String) -> void:
	match id:
		"next":
			world["selectWorld"] = 0
			$load/AnimationPlayer.play("load")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "load" and world["selectWorld"] == 0:
		$Panel/Id.text = "ID planet: RoP-856/%02d" % randi_range(10, 99)
		world["selectWorld"] = 1
		world["selectWorldName"] = $Panel/Id.text
