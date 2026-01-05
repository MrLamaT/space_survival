extends Node3D

var code_input = "" 

func _ready() -> void:
	$mechanism/AnimationPlayer.play("mechanism")

func handle_interaction(object_name: String):
	match object_name:
		"boards":
			if $Sprite3D.visible == true:
				if Global.game_settings["Item"] == "scrap":
					$InteractableObject.remove_from_group("progressive_interactive")
					$Sprite3D.visible = false
					get_node("/root/GlobalMain/NavigationRegion3D/outdoors/StreetWall/InteractableObject").position = Vector3(1.187, 2.793, 2.37)
		"scute":
			if Global.game_settings["Item"] == "WireCutters":
				$scute.queue_free()
				$scute2.visible = true
				Global.game_settings["doorExit"] += 1
				$InteractableObject2.queue_free()
		"0":
			handle_digit_input(object_name)
			$board/MeshInstance3D0.position.y = 0.349
			await get_tree().create_timer(1.0).timeout
			$board/MeshInstance3D0.position.y = 0.589
		"1":
			handle_digit_input(object_name)
			$board/MeshInstance3D1.position.y = 0.349
			await get_tree().create_timer(1.0).timeout
			$board/MeshInstance3D1.position.y = 0.589
		"2":
			handle_digit_input(object_name)
			$board/MeshInstance3D2.position.y = 0.349
			await get_tree().create_timer(1.0).timeout
			$board/MeshInstance3D2.position.y = 0.589
		"3":
			handle_digit_input(object_name)
			$board/MeshInstance3D3.position.y = 0.349
			await get_tree().create_timer(1.0).timeout
			$board/MeshInstance3D3.position.y = 0.589
		"4":
			handle_digit_input(object_name)
			$board/MeshInstance3D4.position.y = 0.349
			await get_tree().create_timer(1.0).timeout
			$board/MeshInstance3D4.position.y = 0.589
		"5":
			handle_digit_input(object_name)
			$board/MeshInstance3D5.position.y = 0.349
			await get_tree().create_timer(1.0).timeout
			$board/MeshInstance3D5.position.y = 0.589
		"6":
			handle_digit_input(object_name)
			$board/MeshInstance3D6.position.y = 0.349
			await get_tree().create_timer(1.0).timeout
			$board/MeshInstance3D6.position.y = 0.589
		"7":
			handle_digit_input(object_name)
			$board/MeshInstance3D7.position.y = 0.349
			await get_tree().create_timer(1.0).timeout
			$board/MeshInstance3D7.position.y = 0.589
		"8":
			handle_digit_input(object_name)
			$board/MeshInstance3D8.position.y = 0.349
			await get_tree().create_timer(1.0).timeout
			$board/MeshInstance3D8.position.y = 0.589
		"9":
			handle_digit_input(object_name)
			$board/MeshInstance3D9.position.y = 0.349
			await get_tree().create_timer(1.0).timeout
			$board/MeshInstance3D9.position.y = 0.589
		"CodeNull":
			reset_code()
			$board/MeshInstance3DNULL.position.y = 0.349
			await get_tree().create_timer(1.0).timeout
			$board/MeshInstance3DNULL.position.y = 0.589
		"mechanism":
			if Global.game_settings["Item"] == "gear":
				get_node("/root/GlobalMain/Player").clear_item()
				if $mechanism/Sprite3D.visible:
					$mechanism/Sprite3D2.visible = true
					Global.game_settings["doorExit"] += 1
					$mechanism/InteractableObject.queue_free()
				else:
					$mechanism/Sprite3D.visible = true

func handle_digit_input(digit: String):
	if code_input.length() < 4:
		code_input += digit
		var display_text = ""
		for i in range(code_input.length()):
			display_text += code_input[i]
		for i in range(code_input.length(), 4):
			display_text += "_"
		$board/MeshInstance3DLabel/Label3D.text = display_text
		if code_input.length() == 4:
			if code_input == Global.game_settings["password"]:
				Global.game_settings["doorExit"] += 1
				$board/MeshInstance3DLabel/Label3D.modulate = Color(0.0, 1.0, 0.0, 1.0)
				$board/MeshInstance3D0/InteractableObject.queue_free()
				$board/MeshInstance3D1/InteractableObject.queue_free()
				$board/MeshInstance3D2/InteractableObject.queue_free()
				$board/MeshInstance3D3/InteractableObject.queue_free()
				$board/MeshInstance3D4/InteractableObject.queue_free()
				$board/MeshInstance3D5/InteractableObject.queue_free()
				$board/MeshInstance3D6/InteractableObject.queue_free()
				$board/MeshInstance3D7/InteractableObject.queue_free()
				$board/MeshInstance3D8/InteractableObject.queue_free()
				$board/MeshInstance3D9/InteractableObject.queue_free()
				$board/MeshInstance3DNULL/InteractableObject.queue_free()
			else:
				reset_code()
				$board/MeshInstance3DLabel/Label3D.modulate = Color(1.0, 0.0, 0.0, 1.0)
				await get_tree().create_timer(1.0).timeout
				$board/MeshInstance3DLabel/Label3D.modulate = Color(1.0, 1.0, 1.0, 1.0)

func reset_code():
	code_input = ""
	$board/MeshInstance3DLabel/Label3D.text = "____"
