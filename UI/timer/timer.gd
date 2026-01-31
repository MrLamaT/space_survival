extends Node2D

var current_value: int = 0

func start_countdown(initial_value: int) -> void:
	current_value = initial_value
	$Label.text = str(current_value)
	$Timer.start()
	visible = true

func _on_timer_timeout() -> void:
	current_value -= 1
	$Label.text = str(current_value)
	if current_value <= 0:
		var player = get_tree().get_first_node_in_group("player")
		player.get_node("head/Camera3D/Teleport").kill()
		$Timer.stop()
		visible = false
