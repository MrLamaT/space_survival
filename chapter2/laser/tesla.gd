extends StaticBody3D

func _on_timer_timeout() -> void:
	$Laser._on_timer_timeout()
	$Laser2._on_timer_timeout()
	$Laser3._on_timer_timeout()
	$Laser4._on_timer_timeout()
	$Laser5._on_timer_timeout()
	$Laser6._on_timer_timeout()
