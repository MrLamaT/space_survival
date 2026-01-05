extends Node3D

func _ready() -> void:
	$AnimationPlayer.play("light")
	$On.play("OnSystem")
	$fans.play()

func handle_interaction(object_name: String):
	match object_name:
		"skin":
			if !Global.game_settings["ModSkin"]: 
				$ModSkin/Node3D/Sprite3D.texture = preload("res://chapter2/assets/ModIcon/Mod1_1.png")
			else:
				$ModSkin/Node3D/Sprite3D.texture = preload("res://chapter2/assets/ModIcon/Mod1_0.png")
			Global.game_settings["ModSkin"] = !Global.game_settings["ModSkin"]
		"season":
			if !Global.game_settings["ModSeason"]: 
				$ModEye/Node3D/Sprite3D.texture = preload("res://chapter2/assets/ModIcon/Mod2_1.png")
			else:
				$ModEye/Node3D/Sprite3D.texture = preload("res://chapter2/assets/ModIcon/Mod2_0.png")
			Global.game_settings["ModSeason"] = !Global.game_settings["ModSeason"]
		"enemy":
			if !Global.game_settings["ModScar"]: 
				$ModScar/Node3D/Sprite3D.texture = preload("res://chapter2/assets/ModIcon/Mod3_1.png")
			else:
				$ModScar/Node3D/Sprite3D.texture = preload("res://chapter2/assets/ModIcon/Mod3_0.png")
			Global.game_settings["ModScar"] = !Global.game_settings["ModScar"]
			Global.game_settings["ModEye"] = Global.game_settings["ModScar"]
		"Traps":
			if !Global.game_settings["ModTraps"]: 
				$ModTraps/Node3D/Sprite3D.texture = preload("res://chapter2/assets/ModIcon/Mod6_1.png")
			else:
				$ModTraps/Node3D/Sprite3D.texture = preload("res://chapter2/assets/ModIcon/Mod6_0.png")
			Global.game_settings["ModTraps"] = !Global.game_settings["ModTraps"]
		"hard":
			if !Global.game_settings["ModHard"]: 
				$Modhard/Node3D/Sprite3D.texture = preload("res://chapter2/assets/ModIcon/Mod7_1.png")
				$Player.DarkHardMod(true)
			else:
				$Modhard/Node3D/Sprite3D.texture = preload("res://chapter2/assets/ModIcon/Mod7_0.png")
				$Player.DarkHardMod(false)
			Global.game_settings["ModHard"] = !Global.game_settings["ModHard"]
		_:
			print("Unknown interaction: ", object_name)


func _on_on_animation_finished(_anim_name: StringName) -> void:
	$Light2.On()
	await get_tree().create_timer(1.5).timeout
	$menu.On()


func _on_fans_finished() -> void:
	$fans.play()
