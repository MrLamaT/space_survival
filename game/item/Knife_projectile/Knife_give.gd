extends Area3D

var task = false

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and !task:
		$handItem.queue_free()
		var world = Global.get_world(Global.game_settings.word)
		world["weapon"][0] = "Vibro Spike"
		body.weapon_system.weapon_slots[1] = "Vibro Spike"
		body.weapon_system.equip_weapon(body.weapon_system.weapon_slots.get(1, ""))
		if Global.game_settings["gui_settings"]["Language"] == "русский":
			body.warning("ЛКМ - удар")
		else:
			body.warning("LMB - strike")
		task = true
