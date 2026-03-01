extends Node3D

@export var OnDefault = false

func _ready() -> void:
	if OnDefault:
		on(false)

func on(reverse):
	if reverse:
		$AnimationPlayer.play_backwards("On")
		$AnimationPlayer2.stop()
	else:
		$AnimationPlayer.play("On")
		$AnimationPlayer2.play("pole")
