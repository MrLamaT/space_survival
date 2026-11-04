extends "res://game/rooms/BaseMaps.gd"

func handle_interaction(object_name: String):
	match object_name:
		"secret":
			$NavigationRegion3D/ImpenetrableField2.on(true)
			$Player.warning("NOTICE_FIELD_OPEN")
