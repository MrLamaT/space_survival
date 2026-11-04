extends NavigationRegion3D

func handle_interaction(object_name: String):
	match object_name:
		"room5":
			$ImpenetrableField5.on(true)
			var player = get_tree().get_first_node_in_group("player")
			player.warning("NOTICE_FIELD_OPEN")

func activate_trigger(object_name: String):
	match object_name:
		"boss":
			$floor_ceiling/room5/RisingRing.on()
			$floor_ceiling/room5/RisingRing2.on()
			$floor_ceiling/room5/RisingRing3.on()
			$floor_ceiling/room5/RisingRing4.on()
			$floor_ceiling/room5/RisingRing5.on()
			$floor_ceiling/room5/RisingRing6.on()
