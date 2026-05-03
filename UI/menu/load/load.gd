extends Node2D

func _input(event):
	if event.is_action_pressed("ui_cancel") and visible == true and $AnimationPlayer.is_playing():
		$AnimationPlayer.stop()
		visible = false
		$beep.play()
		get_parent().get_node("menu").visible = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func intro():
	$AnimationPlayer.play("text_intro")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "text_intro":
		visible = false
		get_parent().get_node("menu").visible = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
