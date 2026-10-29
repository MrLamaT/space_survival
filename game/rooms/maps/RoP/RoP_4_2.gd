extends NavigationRegion3D

func handle_interaction(object_name: String):
	match object_name:
		"room4":
			$floor_ceiling/corridor12/ImpenetrableField.on(true)
			var player = get_tree().get_first_node_in_group("player")
			if Global.game_settings["gui_settings"]["Language"] == "русский":
				player.warning("Непробиваемое поле открылось")
			else:
				player.warning("The Impenetrable Field has opened")
