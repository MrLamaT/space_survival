extends AudioStreamPlayer2D

func _ready() -> void:
	_check_and_play_custom_music()

func _process(_delta: float) -> void:
	if Global.game_settings["UI"]:
		volume_db = -5.0
	else:
		volume_db = 0.0

func _check_and_play_custom_music() -> bool:
	Global.save(0)
	if not Global.game_settings.get("music", ""):
		stop()
		return false
	var music_path = "user://music/" + Global.game_settings["music"]
	var full_path = ProjectSettings.globalize_path(music_path)
	if not FileAccess.file_exists(full_path):
		return false
	var file = FileAccess.open(full_path, FileAccess.READ)
	if not file:
		return false
	var audio_data = file.get_buffer(file.get_length())
	file.close()
	var audio_stream = AudioStreamMP3.new()
	audio_stream.data = audio_data
	if audio_stream:
		stream = audio_stream
		play()
		return true
	return false

func _on_finished() -> void:
	play()
