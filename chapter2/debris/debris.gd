extends StaticBody3D

var is_dying: bool = false

func die():
	if is_dying:
		return
	is_dying = true
	$sparkDead.emitting = true
	$shock.pitch_scale = randf_range(0.9, 1.1)
	$shock.play()
	await get_tree().create_timer(2).timeout
	queue_free()

func take_damage(_damage):
	die()
