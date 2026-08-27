extends Node3D

@export var OnDefault = false
@export var hacking = true

func _ready() -> void:
	if OnDefault:
		on(false)
	if !hacking:
		$PC1.queue_free()

func on(reverse):
	if reverse:
		$AnimationPlayer.play_backwards("On")
	else:
		$AnimationPlayer.play("On")
