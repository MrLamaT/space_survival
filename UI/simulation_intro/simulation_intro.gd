extends Node2D

@export var typing_speed: float = 0.05

func _ready() -> void:
	start_typing_effect("LOADING: SIMULATION v.7.1 \nSIMULATION: BATTLE PREPARATION PROTOCOL \nARCHITECT: CITADEL R&D")

func start_typing_effect(full_text: String) -> void:
	$Panel/Label.text = ""
	await type_text(full_text)
	await get_tree().create_timer(1).timeout
	$AnimationPlayer.play("stop")
	await get_tree().create_timer(1).timeout
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Global.game_settings["UI"] = false
	queue_free()

func type_text(text: String) -> void:
	for i in range(text.length()):
		$Panel/Label.text += text[i]
		await get_tree().create_timer(typing_speed).timeout
