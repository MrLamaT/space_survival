extends Node2D

func teleport():
	$AnimationPlayer.play("teleport")

func kill():
	$AnimationPlayer.play("kill")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "kill":
		var player = get_tree().get_first_node_in_group("player")
		player.HP(100)
