extends Node3D

@export var OnDefault = false

func _ready() -> void:
	if OnDefault:
		on(false)

func on(reverse):
	if reverse:
		$AnimationPlayer.play_backwards("On")
	else:
		$AnimationPlayer.play("On")
