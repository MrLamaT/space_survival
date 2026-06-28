extends Node2D

func handle_card_pressed(type, id):
	match type:
		"skybox":
			match id:
				"Void":
					_replace_skybox(preload("res://chapter2/sky/skybox.tscn"))
				"Clear Sky":
					_replace_skybox(preload("res://chapter2/sky/skyboxBlue.tscn"))
				"Toxic Haze":
					_replace_skybox(preload("res://chapter2/sky/skyboxToxic.tscn"))
				"Crimson Dawn":
					_replace_skybox(preload("res://chapter2/sky/skyboxBlood.tscn"))
				"Rust Storm":
					_replace_skybox(preload("res://chapter2/sky/skyboxRust.tscn"))
				"Pale Dawn":
					_replace_skybox(preload("res://chapter2/sky/skyboxPale.tscn"))
				"Dusk":
					_replace_skybox(preload("res://chapter2/sky/skyboxDusk.tscn"))

func _replace_skybox(new_skybox_scene: PackedScene) -> void:
	var world_environment = get_tree().get_first_node_in_group("skybox")
	if not world_environment:
		return
	var parent = world_environment.get_parent()
	var index = world_environment.get_index()
	world_environment.queue_free()
	var env_instance = new_skybox_scene.instantiate()
	parent.add_child(env_instance)
	parent.move_child(env_instance, index)
