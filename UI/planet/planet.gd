extends Node2D

var world = Global.get_world(Global.game_settings.word)

func _ready() -> void:
	if world["selectWorld"] != "":
		$load/AnimationPlayer.play("load")
		$load/AnimationPlayer.advance($load/AnimationPlayer.current_animation_length)
		$Panel/Id.text = world["selectWorld"]
	else:
		$load/AnimationPlayer.play("load")

func _on_label_button_pressed(id: String) -> void:
	match id:
		"next":
			world["selectWorld"] = ""
			$load/AnimationPlayer.play("load")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "load" and world["selectWorld"] == "":
		$Panel/Id.text = "ID planet: RoP-856"
		world["selectWorld"] = $Panel/Id.text
		var keys_to_remove = []
		for key in world["inventory"].keys():
			if key is String and "chest_W" in key:
				keys_to_remove.append(key)
		for key in keys_to_remove:
			world["inventory"].erase(key)
