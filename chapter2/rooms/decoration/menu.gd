extends Area3D

func On():
	$AnimationPlayer.play("intro")
	
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "intro":
		$beep.play()
		$AnimationPlayer.play("textIntro")
	elif anim_name == "textIntro":
		$monitor/INITIALIZED.visible = false
		$AnimationPlayer.play("Flowy")
	elif anim_name == "Flowy":
		$monitor/Sprite3D2.visible = true
		$beep.play()
