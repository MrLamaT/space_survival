extends Node

var world = Global.get_world(Global.game_settings.word)

@export var env_scene: PackedScene

func _ready() -> void:
	if env_scene:
		var env_instance = env_scene.instantiate()
		add_child(env_instance)
