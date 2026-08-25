extends NavigationRegion3D

func handle_interaction(object_name: String):
	match object_name:
		"room5":
			$ImpenetrableField5.on(true)
			if Global.game_settings["gui_settings"]["Language"] == "русский":
				$Player.warning("Непробиваемое поле открылось")
			else:
				$Player.warning("The Impenetrable Field has opened")
