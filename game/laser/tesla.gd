extends StaticBody3D

func _on_timer_timeout() -> void:
	for i in range(1, 7):
		get_node("Laser%d" % i).toggle()
