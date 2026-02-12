extends Node3D

func on(reverse):
	if reverse:
		$AnimationPlayer.play_backwards("On")
	else:
		$AnimationPlayer.play("On")
