extends "res://game/rooms/BaseMaps.gd"

func _on_audio_stream_player_2d_finished() -> void:
	$AudioStreamPlayer2D.play()
