extends Area3D


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		$AnimationPlayer.play("poison")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "poison":
		var poison_smok_scene = load("res://chapter2/poison/poisonSmok.tscn")
		var poison_smok_instance = poison_smok_scene.instantiate()
		poison_smok_instance.type = "player"
		get_parent().add_child(poison_smok_instance)
		poison_smok_instance.global_position = global_position
		queue_free()
