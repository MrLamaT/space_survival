extends "res://game/rooms/BaseMaps.gd"

func handle_interaction(object_name: String):
	match object_name:
		"secret":
			$NavigationRegion3D/ImpenetrableField.on(true)
			if Global.game_settings["gui_settings"]["Language"] == "русский":
				$Player.warning("Непробиваемое поле открылось")
			else:
				$Player.warning("The Impenetrable Field has opened")
