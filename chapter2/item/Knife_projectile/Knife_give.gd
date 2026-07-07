extends Area3D

var task = false

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and !task:
		$handItem.queue_free()
		body.weapon_system.weapon_slots[1] = "Knife"
		body.weapon_system.equip_weapon(body.weapon_system.weapon_slots.get(1, ""))
		if Global.game_settings["gui_settings"]["Language"] == "русский":
			body.warning("ЛКМ - удар")
		else:
			body.warning("LMB - strike")
		task = true
