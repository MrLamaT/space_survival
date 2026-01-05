extends Control

func _ready() -> void:
	$AnimationPlayer.play("load")

func update_progress(value: float):
	if has_node("ProgressBar"):
		$ProgressBar.value = value
