extends NavigationRegion3D

func handle_interaction(object_name: String):
	match object_name:
		"room3":
			$floor_ceiling/corridor12/ImpenetrableField.on(true)
			var player = get_tree().get_first_node_in_group("player")
			player.warning("NOTICE_FIELD_OPEN")
