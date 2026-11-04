extends "res://game/rooms/BaseMaps.gd"

func handle_interaction(object_name: String):
	match object_name:
		"room1":
			$NavigationRegion3D/floor_ceiling/room1/wallGates3.unlocking()
			$NavigationRegion3D/floor_ceiling/room3/wallGates.unlocking()
			$Player.warning("NOTICE_PASSAGE_OPEN")
		"room5":
			$NavigationRegion3D/floor_ceiling/room5/ImpenetrableField.on(true)
			$Player.warning("NOTICE_FIELD_OPEN")
